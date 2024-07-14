import React, { useState } from 'react';
import axios from 'axios';

const BlockScoutTransactions = () => {
  const [address, setAddress] = useState('');
  const [transactions, setTransactions] = useState([]);
  const [error, setError] = useState('');

  const handleAddressChange = (event) => {
    setAddress(event.target.value);
  };

  const fetchTransactions = async () => {
    try {
      const response = await axios.get(`https://blockscout.com/eth/mainnet/api?module=account&action=txlist&address=${address}`);
      if (response.status === 200) {
        setTransactions(response.data.result);
        setError('');
      } else {
        setError('Error fetching data');
      }
    } catch (error) {
      console.error('Error fetching data:', error);
      setError('Error fetching data');
    }
  };

  return (
    <div>
      <h2>BlockScout Transactions</h2>
      <div>
        <label htmlFor="addressInput">Enter Ethereum Address:</label>{' '}
        <input id="addressInput" type="text" value={address} onChange={handleAddressChange} />
        <button onClick={fetchTransactions}>Fetch Transactions</button>
      </div>
      {error && <p>{error}</p>}
      <div>
        {transactions.length > 0 ? (
          <div>
            <h3>Last 10 Transactions:</h3>
            <ul>
              {transactions.slice(0, 10).map((tx, index) => (
                <li key={index}>
                  <strong>Hash:</strong> {tx.hash}<br />
                  <strong>From:</strong> {tx.from}<br />
                  <strong>To:</strong> {tx.to}<br />
                  <strong>Value:</strong> {tx.value} wei
                </li>
              ))}
            </ul>
          </div>
        ) : (
          <p>No transactions found.</p>
        )}
      </div>
    </div>
  );
};

export default BlockScoutTransactions;
