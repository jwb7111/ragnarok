import { BrowserRouter, Routes, Route } from 'react-router-dom'

// Placeholder components - will be implemented as frameworks are wired
const Dashboard = () => <div>Dashboard - Coming Soon</div>
const Invoices = () => <div>Invoices - Coming Soon</div>
const Settings = () => <div>Settings - Coming Soon</div>

export function App() {
  return (
    <BrowserRouter>
      <div className="app">
        <header>
          <h1>Invoice Tracker POC</h1>
          <nav>
            <a href="/">Dashboard</a>
            <a href="/invoices">Invoices</a>
            <a href="/settings">Settings</a>
          </nav>
        </header>
        <main>
          <Routes>
            <Route path="/" element={<Dashboard />} />
            <Route path="/invoices" element={<Invoices />} />
            <Route path="/settings" element={<Settings />} />
          </Routes>
        </main>
        <footer>
          <p>Loki Mode POC - Demonstrating Framework Integration</p>
        </footer>
      </div>
    </BrowserRouter>
  )
}
