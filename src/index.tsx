import { StrictMode } from 'react';
import { createRoot } from 'react-dom/client';
import App from './App.tsx';
import { CHAIN_ID, PROJECT_ID, RELAY_URL } from './constants/env.ts';
import { JsonRpcProvider } from './contexts/JsonRpcContext.tsx';
import { WalletConnectProvider } from './contexts/WalletConnectContext.tsx';


const root = createRoot(document.querySelector('#root')!);

root.render(
    <StrictMode>
        <WalletConnectProvider
            projectId={PROJECT_ID}
            relayUrl={RELAY_URL}
            chainId={CHAIN_ID}
        >
            <JsonRpcProvider>
                <App />
            </JsonRpcProvider>
        </WalletConnectProvider>
    </StrictMode>
);
