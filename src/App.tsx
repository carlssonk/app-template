import './App.css'

function App() {

  return (
    <>
      <h1>:D</h1>
      <p style={{ fontSize: '0.8em', opacity: 0.5, marginTop: '2rem' }}>
        Version: {__COMMIT_HASH__}
      </p>
    </>
  )
}

export default App
