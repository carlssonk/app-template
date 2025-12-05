// Cloudflare Worker for version-based routing with percentage rollouts
const DEFAULT_HASH = 'main'; // Fallback if KV lookup fails

addEventListener('fetch', event => {
  event.respondWith(handleRequest(event.request))
})

async function handleRequest(request) {
  try {
    const bucketName = S3_BUCKET_NAME;
    
    // Get rollout configuration from KV
    const rolloutConfigJson = await VERSION_KV.get('rollout_config');
    
    let hash;
    if (rolloutConfigJson) {
      // Percentage-based rollout is active
      const config = JSON.parse(rolloutConfigJson);
      hash = await selectVersionByPercentage(request, config);
    } else {
      // Simple mode: just use current_version
      hash = await VERSION_KV.get('current_version') || DEFAULT_HASH;
    }

    // Construct the S3 URL with the hash prefix
    const url = new URL(request.url);
    url.hostname = `${bucketName}.s3.amazonaws.com`;
    url.pathname = `/${hash}${url.pathname}`;

    // Fetch the content from S3 with proper error handling
    const response = await fetch(url, {
      method: request.method,
      headers: {
        'Host': url.hostname,
        'User-Agent': request.headers.get('User-Agent') || '',
      },
      cf: {
        cacheTtl: 3600, // Cache S3 responses for 1 hour
        cacheEverything: true,
      }
    });

    if (!response.ok) {
      // If specific version fails, try fallback
      if (hash !== DEFAULT_HASH) {
        const fallbackUrl = new URL(request.url);
        fallbackUrl.hostname = `${bucketName}.s3.amazonaws.com`;
        fallbackUrl.pathname = `/${DEFAULT_HASH}${fallbackUrl.pathname}`;
        
        const fallbackResponse = await fetch(fallbackUrl, {
          method: request.method,
          headers: {
            'Host': fallbackUrl.hostname,
          },
          cf: {
            cacheTtl: 3600,
            cacheEverything: true,
          }
        });
        
        if (fallbackResponse.ok) {
          console.log(`Fallback successful: serving '${DEFAULT_HASH}' instead of '${hash}'`);
          return createResponse(fallbackResponse, DEFAULT_HASH, true, hash);
        }
        
        console.error(`Fallback to '${DEFAULT_HASH}' also failed (${fallbackResponse.status})`);
      }
      
      return new Response('Content not found', { status: 404 });
    }

    return createResponse(response, hash, false, null);
  } catch (error) {
    console.error('Worker error:', error);
    // Don't expose internal error details
    return new Response('Service temporarily unavailable', {
      status: 503,
      headers: {
        'Content-Type': 'text/plain',
        'Retry-After': '60',
      },
    });
  }
}

/**
 * Select version based on percentage rollout configuration
 * Uses consistent hashing based on user IP to ensure same user gets same version
 */
async function selectVersionByPercentage(request, config) {
  // Get user identifier (IP address for consistent assignment)
  const userIdentifier = request.headers.get('CF-Connecting-IP') || 'anonymous';
  
  // Hash the user identifier to get a number between 0-99
  const hashValue = await hashString(userIdentifier);
  const percentage = hashValue % 100;
  
  // config format: { "versions": [{"hash": "abc123", "percentage": 10}, {"hash": "latest", "percentage": 90}] }
  let cumulativePercentage = 0;
  for (const version of config.versions) {
    cumulativePercentage += version.percentage;
    if (percentage < cumulativePercentage) {
      return version.hash;
    }
  }
  
  // Fallback to last version if percentages don't add up to 100
  return config.versions[config.versions.length - 1].hash;
}

/**
 * Simple hash function to convert string to number
 */
async function hashString(str) {
  const encoder = new TextEncoder();
  const data = encoder.encode(str);
  const hashBuffer = await crypto.subtle.digest('SHA-256', data);
  const hashArray = Array.from(new Uint8Array(hashBuffer));
  // Use first 4 bytes to create a number
  return hashArray[0] + (hashArray[1] << 8) + (hashArray[2] << 16) + (hashArray[3] << 24);
}

function createResponse(originalResponse, hash, isFallback, requestedHash) {
  const response = new Response(originalResponse.body, originalResponse);
  
  // Set appropriate CORS headers (adjust for your domain)
  const origin = response.headers.get('origin');
  if (origin && (origin.endsWith('.carlssonk.se') || origin === 'https://carlssonk.se')) {
    response.headers.set('Access-Control-Allow-Origin', origin);
    response.headers.set('Access-Control-Allow-Credentials', 'true');
  }
  
  // Add version headers
  response.headers.set('X-Website-Version', hash);
  
  if (isFallback) {
    response.headers.set('X-Fallback-Used', 'true');
    if (requestedHash) {
      response.headers.set('X-Requested-Version', requestedHash);
    }
  }
  
  // Security headers
  response.headers.set('X-Content-Type-Options', 'nosniff');
  response.headers.set('X-Frame-Options', 'SAMEORIGIN');
  
  return response;
}