import './App.css'

function App() {

  return (
    <div>
      <h1>Latest Version :D</h1>
      <p style={{ fontSize: '0.8em', opacity: 0.5, marginTop: '2rem' }}>
        Version: {__COMMIT_HASH__}
      </p>
    </div>
  )
}

export default App
