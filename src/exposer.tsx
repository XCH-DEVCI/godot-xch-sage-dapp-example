import { useEffect } from 'react';
import { useWalletConnect } from './contexts/WalletConnectContext'; // Import the WalletConnect hook
import { useJsonRpc } from './contexts/JsonRpcContext';

export function WalletConnectInterface() {
    // Use the hook as part of a React component
    const { client, session, pairings, connect, disconnect } = useWalletConnect();
    const rpc = useJsonRpc();
    useEffect(() => {
        // Attach the WalletConnect functionality to the global window object
        window.gd_useWalletConnect = (term: string) => {
            const parsed_inputs = term.split(";"); // Parse input by ";"
            const command = parsed_inputs[0];
            if (term != "session;") {
                console.log("Received a command: " + command);
            }
            try {
                switch (command) {
                    case "client":
                        return client; // Return the WalletConnect client object
                    case "session":
                        return session; // Return the current WalletConnect session
                    case "pairings":
                        return pairings; // Return the active pairings
                    case "connect":
                        if (!client) {
                            throw new Error("WalletConnect client is not initialized.");
                        }

                        if (pairings.length === 1) {
                            connect({ topic: pairings[0].topic }); // Automatically connect if only one pairing exists
                        } else if (pairings.length > 1) {
                            console.warn("Multiple pairings detected. Modal handling is not implemented.", pairings);
                        } else {
                            connect(); // Standard connect method
                        }
                        return null;
                    case "disconnect":
                        disconnect(); // Disconnect the active session
                        localStorage.clear();
                        window.location.href = '';
                        return null;
                    case "send":
                        if (!client || !session) {
                            throw new Error("WalletConnect session is not active.");
                        }
                        if (parsed_inputs.length < 3) {
                            throw new Error(
                                "Invalid inputs. Format: send;<recipient_address>;<amount>;<fee>"
                            );
                        }
                        const address = parsed_inputs[1];
                        const amount = parseInt(parsed_inputs[2]);
                        const fee = parseInt(parsed_inputs[3]);
                        if (!address || isNaN(amount) || isNaN(fee)) {
                            throw new Error(
                                "Invalid recipient address, amount, or fee. Please check your input."
                            );
                        }
                        return rpc.send({
                            address,
                            amount,
                            fee,
                            assetId: undefined,
                            memos: undefined,
                        }).then((sendResult) => {
                            return sendResult;
                        }).catch((error) => {
                            console.error("Error sending XCH:", error);
                            throw error;
                        });

                    case "chainId":
                        return rpc.chainId({})
                            .then((chainIdResult) => {
                                const result = String(chainIdResult)
                                return result; // Return the resolved value
                            })
                            .catch((error) => {
                                console.error("Error fetching Chain ID:", error);
                                throw error; // Handle errors appropriately
                            });
                    case "fetch_nfts":
                        const offset = 0;
                        const limit = 10;
                        return rpc.getNfts({
                            collectionId: undefined,
                            offset,
                            limit,
                        }).then((fetchResult) => {
                            const nfts = fetchResult.nfts;
                            const jsonString = JSON.stringify(nfts, null, 2);
                            console.log(jsonString);
                            return jsonString;
                        }).catch((error) => {
                            console.error("Error fetching NFT:", error);
                            throw error;
                        });
                    default:
                        console.error(`Invalid term provided to gd_useWalletConnect: "${term}"`);
                        return null; // Handle invalid terms
                }
            } catch (error) {
                console.error("Error in gd_useWalletConnect:", error);
                return null;
            }
        };
    }, [client, session, pairings, connect, disconnect]);

    return null; // This component doesn't render anything
}

