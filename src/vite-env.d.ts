/// <reference types="vite/client" />
interface Window {
    gd_useWalletConnect: (term: string) => any;
    onConnect: () => void;
}
