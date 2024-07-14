import '../styles/globals.css';
import '@rainbow-me/rainbowkit/styles.css';
import type { AppProps } from 'next/app';

import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { WagmiProvider } from 'wagmi';
import { RainbowKitProvider } from '@rainbow-me/rainbowkit';
import { getDefaultConfig } from '@rainbow-me/rainbowkit';


import { scrollSepolia } from 'viem/chains';

const config = getDefaultConfig({
  appName: 'FairShare',
  projectId: '55cbeeeb8385618ff980349ccbfb6898',
  chains: [scrollSepolia],
  ssr: true, // Eğer dApp'iniz sunucu tarafı oluşturma (SSR) kullanıyorsa true olarak ayarlayın
});

const client = new QueryClient();

function MyApp({ Component, pageProps }: AppProps) {
  return (
    <WagmiProvider config={config}>
      <QueryClientProvider client={client}>
        <RainbowKitProvider>
          <Component {...pageProps} />
        </RainbowKitProvider>
      </QueryClientProvider>
    </WagmiProvider>
  );
}

export default MyApp;
