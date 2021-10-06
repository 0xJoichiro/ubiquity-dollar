/* eslint-disable @typescript-eslint/explicit-module-boundary-types */
import { BigNumber, ethers } from "ethers";
import React, { useState, useEffect } from "react";

import { EthAccount } from "./common/types";
import Account from "./account";
import BondingMigrate from "./bonding.migrate";
import { useConnectedContext } from "./context/connected";
import CurveBalance from "./curve.balance";
import CurveLPBalance from "./curveLP.balance";
import DebtCouponBalance from "./debtCoupon.balance";
import DebtCouponDeposit from "./debtCoupon.deposit";
import DebtCouponRedeem from "./debtCoupon.redeem";
import TwapPrice from "./twap.price";
import UadBalance from "./uad.balance";
import UarBalance from "./uar.balance";
import UarRedeem from "./uar.redeem";
import UbqBalance from "./ubq.balance";
import BondingSharesExplorer from "./BondingSharesExplorer";

const PROD = process.env.NODE_ENV == "production";

async function fetchAccount(): Promise<EthAccount | null> {
  if (window.ethereum?.request) {
    return {
      address: ((await window.ethereum.request({
        method: "eth_requestAccounts",
      })) as string[])[0],
      balance: 0,
    };
  } else {
    alert("MetaMask is not installed!");
    console.error("MetaMask is not installed, cannot connect wallet");
    return null;
  }
}

export function _renderControls() {
  const { setAccount, account, balances, twapPrice } = useConnectedContext();
  const [connecting, setConnecting] = useState(false);

  const connect = async (): Promise<void> => {
    setConnecting(true);
    setAccount(await fetchAccount());
  };

  if (!PROD) {
    useEffect(() => {
      connect();
    }, []);
  }

  return (
    <>
      <div id="background">
        {PROD && <video src="ubiquity-one-fifth-speed-trimmed-compressed.mp4" autoPlay muted loop playsInline></video>}
        <div id="grid"></div>
      </div>
      <div id="common">
        <header>
          <div id="logo">
            <span>Ubiquity Dollar</span>
            <span>|</span>
            <span>Staking Dashboard</span>
            <span></span>
          </div>
          <div>
            <span>
              <input type="button" value="Connect Wallet" disabled={connecting} onClick={() => connect()} />
            </span>
          </div>

          <Account />
        </header>

        {account && <TwapPrice />}
        <BondingMigrate />
        {account && <BondingSharesExplorer />}
        {balances?.uar.gt(BigNumber.from(0)) && twapPrice?.gte(ethers.utils.parseEther("1")) ? <UarRedeem /> : ""}
        {twapPrice?.lte(ethers.utils.parseEther("1")) ? <DebtCouponDeposit /> : ""}
        {balances?.debtCoupon.gt(BigNumber.from(0)) ? <DebtCouponRedeem /> : ""}

        <div id="markets">
          <div>
            <aside> Primary Markets</aside>
          </div>
          <div>
            <div id="uad-market">
              <div>
                <span>
                  <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 131.66 150">
                    <path d="m54.5 97.23.51.29L95.45 121l-27.54 16a5.44 5.44 0 0 1-5.11.16l-.29-.16-49.1-28.35a5.42 5.42 0 0 1-2.69-4.36v-8.7a48.08 48.08 0 0 1 43.78 1.7zm-30.45-60.7 42.73 24.8.55.32a59 59 0 0 0 52.38 2.77v39.48a5.4 5.4 0 0 1-2.44 4.51l-.26.18-10.67 6.14-45.85-26.61a58.92 58.92 0 0 0-49.78-4.38v-36.4a5.42 5.42 0 0 1 2.44-4.51l.26-.16zm41.16-22.87a5.43 5.43 0 0 1 2.38.55l.32.17L117 42.67a5.4 5.4 0 0 1 2.7 4.35v5.33a48 48 0 0 1-46.8 0l-.64-.35-37.34-21.73 27.59-15.89a5.25 5.25 0 0 1 2.35-.72zm66.45 27.11a6.54 6.54 0 0 0-3.27-5.66L69.1.87a6.58 6.58 0 0 0-6.54 0L3.27 35.11A6.54 6.54 0 0 0 0 40.77v68.46a6.57 6.57 0 0 0 3.27 5.67l59.29 34.23a6.58 6.58 0 0 0 6.54 0l59.29-34.23a6.57 6.57 0 0 0 3.27-5.67z" />
                  </svg>
                </span>
                <span>uAD</span>
              </div>
              <div>
                <a target="_blank" href="https://crv.to">
                  <input type="button" value="Swap" />
                </a>
              </div>
              <div>
                <a target="_blank" href="https://crv.to/pool">
                  <input type="button" value="Deposit" />
                </a>
              </div>
            </div>
            <div id="ubq-market">
              <div>
                <span>
                  <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 91.57 104.19">
                    <path d="M43.28.67 2.5 24.22A5 5 0 0 0 0 28.55v47.09A5 5 0 0 0 2.5 80l40.78 23.55a5 5 0 0 0 5 0L89.07 80a5 5 0 0 0 2.5-4.33V28.55a5 5 0 0 0-2.5-4.33L48.28.67a5 5 0 0 0-5 0zm36.31 25a2 2 0 0 1 0 3.46l-6 3.48c-2.72 1.57-4.11 4.09-5.34 6.3-.18.33-.36.66-.55 1-3 5.24-4.4 10.74-5.64 15.6C59.71 64.76 58 70.1 50.19 72.09a17.76 17.76 0 0 1-8.81 0c-7.81-2-9.53-7.33-11.89-16.59-1.24-4.86-2.64-10.36-5.65-15.6l-.54-1c-1.23-2.21-2.62-4.73-5.34-6.3l-6-3.47a2 2 0 0 1 0-3.47L43.28 7.6a5 5 0 0 1 5 0zM43.28 96.59 8.5 76.51A5 5 0 0 1 6 72.18v-36.1a2 2 0 0 1 3-1.73l6 3.46c1.29.74 2.13 2.25 3.09 4l.6 1c2.59 4.54 3.84 9.41 5 14.11 2.25 8.84 4.58 18 16.25 20.93a23.85 23.85 0 0 0 11.71 0C63.3 75 65.63 65.82 67.89 57c1.2-4.7 2.44-9.57 5-14.1l.59-1.06c1-1.76 1.81-3.27 3.1-4l5.94-3.45a2 2 0 0 1 3 1.73v36.1a5 5 0 0 1-2.5 4.33L48.28 96.59a5 5 0 0 1-5 0z" />
                  </svg>
                </span>
                <span>UBQ</span>
              </div>
              <div>
                <a
                  target="_blank"
                  href="https://app.sushi.com/swap?inputCurrency=0x4e38D89362f7e5db0096CE44ebD021c3962aA9a0&outputCurrency=0x0F644658510c95CB46955e55D7BA9DDa9E9fBEc6"
                >
                  <input type="button" value="Swap" />
                </a>
              </div>
              <div>
                <a target="_blank" href="https://app.sushi.com/add/0x4e38D89362f7e5db0096CE44ebD021c3962aA9a0/0x0F644658510c95CB46955e55D7BA9DDa9E9fBEc6">
                  <input type="button" value="Deposit" />
                </a>
              </div>
            </div>
          </div>
        </div>

        {balances && (
          <>
            <div id="inventory-top">
              <div>
                <div>
                  <aside>My Ubiquity Inventory</aside>
                  <figure></figure>
                </div>
                <UadBalance />
                <UarBalance />
                <DebtCouponBalance />
                <UbqBalance />
                <CurveBalance />
                <CurveLPBalance />
              </div>
            </div>
          </>
        )}
      </div>
    </>
  );
}
