//
//  MainTabTokenViewController.swift
//  Cosmostation
//
//  Created by yongjoo on 26/09/2019.
//  Copyright © 2019 wannabit. All rights reserved.
//

import UIKit
import Alamofire
import UserNotifications
import SafariServices

class MainTabTokenViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    let SECTION_NATIVE_GRPC             = 0;
    let SECTION_IBC_AUTHED_GRPC         = 1;
    let SECTION_OSMOSIS_POOL_GRPC       = 2;
    let SECTION_SIF_ETHER_GRPC          = 3;
    let SECTION_IBC_UNKNOWN_GRPC        = 4;
    let SECTION_UNKNOWN_GRPC            = 5;
    
    let SECTION_NATIVE                  = 6;
    let SECTION_KAVA_BEP2               = 7;
    let SECTION_ETC                     = 8;
    let SECTION_UNKNOWN                 = 9;
    

    @IBOutlet weak var titleChainImg: UIImageView!
    @IBOutlet weak var titleWalletName: UILabel!
    @IBOutlet weak var titleAlarmBtn: UIButton!
    @IBOutlet weak var titleChainName: UILabel!
    
    @IBOutlet weak var totalCard: CardView!
    @IBOutlet weak var totalKeyState: UIImageView!
    @IBOutlet weak var totalDpAddress: UILabel!
    @IBOutlet weak var totalValue: UILabel!
    @IBOutlet weak var totalBtcValue: UILabel!
    
    @IBOutlet weak var tokenTableView: UITableView!
    var refresher: UIRefreshControl!
    var mainTabVC: MainTabViewController!
    var mBnbTics = [String : NSMutableDictionary]()
    var mOrder:Int?
    
    var mBalances = Array<Balance>()
    var mBalances_gRPC = Array<Coin>()
    
    var mNative_gRPC = Array<Coin>()                // section 0
    var mIbcAuthed_gRPC = Array<Coin>()             // section 1
    var mOsmosisPool_gRPC = Array<Coin>()           // section 2
    var mSifEther_gRPC = Array<Coin>()              // section 3
    var mIbcUnknown_gRPC = Array<Coin>()            // section 4
    var mUnKnown_gRPC = Array<Coin>()               // section 5
    
    var mNative = Array<Balance>()                  // section 6
    var mKavaBep2 = Array<Balance>()                // section 7
    var mEtc = Array<Balance>()                     // section 8
    var mUnKnown = Array<Balance>()                 // section 9
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.mainTabVC = (self.parent)?.parent as? MainTabViewController
        self.account = BaseData.instance.selectAccountById(id: BaseData.instance.getRecentAccountId())
        self.chainType = WUtils.getChainType(account!.account_base_chain)
        
        self.tokenTableView.delegate = self
        self.tokenTableView.dataSource = self
        self.tokenTableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        self.tokenTableView.register(UINib(nibName: "TokenCell", bundle: nil), forCellReuseIdentifier: "TokenCell")
        self.tokenTableView.rowHeight = UITableView.automaticDimension
        self.tokenTableView.estimatedRowHeight = UITableView.automaticDimension
        
        refresher = UIRefreshControl()
        refresher.addTarget(self, action: #selector(onRequestFetch), for: .valueChanged)
        refresher.tintColor = UIColor.white
        tokenTableView.addSubview(refresher)
        
        self.mBalances = BaseData.instance.mBalances
        self.mBalances_gRPC = BaseData.instance.mMyBalances_gRPC
        
        let tapTotalCard = UITapGestureRecognizer(target: self, action: #selector(self.onClickActionShare))
        self.totalCard.addGestureRecognizer(tapTotalCard)
        
        self.updateView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        self.navigationController?.navigationBar.topItem?.title = "";
        NotificationCenter.default.addObserver(self, selector: #selector(self.onFetchDone(_:)), name: Notification.Name("onFetchDone"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.onFetchPrice(_:)), name: Notification.Name("onFetchPrice"), object: nil)
        self.updateTitle()
        self.updateView()
    }

    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.removeObserver(self, name: Notification.Name("onFetchDone"), object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name("onFetchPrice"), object: nil)
    }
    
    func updateTitle() {
        titleChainName.textColor = WUtils.getChainColor(chainType!)
        if (account?.account_nick_name == "") {
            titleWalletName.text = NSLocalizedString("wallet_dash", comment: "") + String(account!.account_id)
        } else {
            titleWalletName.text = account?.account_nick_name
        }
        
        self.totalCard.backgroundColor = WUtils.getChainBg(chainType)
        if (account?.account_has_private == true) {
            self.totalKeyState.image = totalKeyState.image?.withRenderingMode(.alwaysTemplate)
            self.totalKeyState.tintColor = WUtils.getChainColor(chainType)
        }
        self.totalDpAddress.text = account?.dpAddress(chainType)
        self.totalDpAddress.adjustsFontSizeToFitWidth = true
        self.totalValue.attributedText = WUtils.dpAllAssetValueUserCurrency(chainType, totalValue.font)
        
        if (chainType! == ChainType.COSMOS_MAIN) {
            titleChainImg.image = UIImage(named: "cosmosWhMain")
            titleChainName.text = "(Cosmos Mainnet)"
        } else if (chainType! == ChainType.IRIS_MAIN) {
            titleChainImg.image = UIImage(named: "irisWh")
            titleChainName.text = "(Iris Mainnet)"
            titleAlarmBtn.isHidden = true
        } else if (chainType! == ChainType.BINANCE_MAIN) {
            titleChainImg.image = UIImage(named: "binanceChImg")
            titleChainName.text = "(Binance Mainnet)"
            titleAlarmBtn.isHidden = true
        } else if (chainType! == ChainType.KAVA_MAIN) {
            titleChainImg.image = UIImage(named: "kavaImg")
            titleChainName.text = "(Kava Mainnet)"
            titleAlarmBtn.isHidden = true
        } else if (chainType! == ChainType.IOV_MAIN) {
            titleChainImg.image = UIImage(named: "iovChainImg")
            titleChainName.text = "(Starname Mainnet)"
            titleAlarmBtn.isHidden = true
        }  else if (chainType! == ChainType.BAND_MAIN) {
            titleChainImg.image = UIImage(named: "chainBandprotocal")
            titleChainName.text = "(Band Mainnet)"
            titleAlarmBtn.isHidden = true
        } else if (chainType! == ChainType.SECRET_MAIN) {
            titleChainImg.image = UIImage(named: "secretChainImg")
            titleChainName.text = "(Secret Mainnet)"
            titleAlarmBtn.isHidden = true
        } else if (chainType! == ChainType.CERTIK_MAIN) {
            titleChainImg.image = UIImage(named: "certikChainImg")
            titleChainName.text = "(Certik Mainnet)"
            titleAlarmBtn.isHidden = true
        } else if (chainType! == ChainType.AKASH_MAIN) {
            titleChainImg.image = UIImage(named: "akashChainImg")
            titleChainName.text = "(Akash Mainnet)"
            titleAlarmBtn.isHidden = true
        } else if (chainType! == ChainType.OKEX_MAIN) {
            titleChainImg.image = UIImage(named: "okexChainImg")
            titleChainName.text = "(ExChain Mainnet)"
            titleAlarmBtn.isHidden = true
        } else if (chainType! == ChainType.PERSIS_MAIN) {
            titleChainImg.image = UIImage(named: "chainpersistence")
            titleChainName.text = "(Persistence Mainnet)"
            titleAlarmBtn.isHidden = true
        } else if (chainType! == ChainType.SENTINEL_MAIN) {
            titleChainImg.image = UIImage(named: "chainsentinel")
            titleChainName.text = "(Sentinel Mainnet)"
            titleAlarmBtn.isHidden = true
        } else if (chainType! == ChainType.FETCH_MAIN) {
            titleChainImg.image = UIImage(named: "chainfetchai")
            titleChainName.text = "(Fetch.ai Mainnet)"
            titleAlarmBtn.isHidden = true
        } else if (chainType! == ChainType.CRYPTO_MAIN) {
            titleChainImg.image = UIImage(named: "chaincrypto")
            titleChainName.text = "(Crypto.org Mainnet)"
            titleAlarmBtn.isHidden = true
        } else if (chainType! == ChainType.SIF_MAIN) {
            titleChainImg.image = UIImage(named: "chainsifchain")
            titleChainName.text = "(SifChain Mainnet)"
            titleAlarmBtn.isHidden = true
        } else if (chainType! == ChainType.KI_MAIN) {
            titleChainImg.image = UIImage(named: "chainKifoundation")
            titleChainName.text = "(KiChain Mainnet)"
            titleAlarmBtn.isHidden = true
        } else if (chainType! == ChainType.OSMOSIS_MAIN) {
            titleChainImg.image = UIImage(named: "chainOsmosis")
            titleChainName.text = "(OSMOSIS Mainnet)"
            titleAlarmBtn.isHidden = true
        } else if (chainType! == ChainType.MEDI_MAIN) {
            titleChainImg.image = UIImage(named: "chainMedibloc")
            titleChainName.text = "(Medibloc Mainnet)"
            titleAlarmBtn.isHidden = true
        }
        
        else if (chainType! == ChainType.COSMOS_TEST) {
            titleChainImg.image = UIImage(named: "cosmosTestChainImg")
            titleChainName.text = "(StarGate Testnet)"
            titleAlarmBtn.isHidden = true
        } else if (chainType! == ChainType.IRIS_TEST) {
            titleChainImg.image = UIImage(named: "irisTestChainImg")
            titleChainName.text = "(Bifrost Testnet)"
            titleAlarmBtn.isHidden = true
        } else if (chainType! == ChainType.BINANCE_TEST) {
            titleChainImg.image = UIImage(named: "binancetestnet")
            titleChainName.text = "(Binance Testnet)"
            titleAlarmBtn.isHidden = true
        } else if (chainType! == ChainType.KAVA_TEST) {
            titleChainImg.image = UIImage(named: "kavaTestImg")
            titleChainName.text = "(Kava Testnet)"
            titleAlarmBtn.isHidden = true
        } else if (chainType! == ChainType.IOV_TEST) {
            titleChainImg.image = UIImage(named: "iovTestnetImg")
            titleChainName.text = "(Starname Testnet)"
            titleAlarmBtn.isHidden = true
        } else if (chainType! == ChainType.OKEX_TEST) {
            titleChainImg.image = UIImage(named: "okexTestnetImg")
            titleChainName.text = "(ExChain Testnet)"
            titleAlarmBtn.isHidden = true
        } else if (chainType! == ChainType.CERTIK_TEST) {
            titleChainImg.image = UIImage(named: "certikTestnetImg")
            titleChainName.text = "(Certik Testnet)"
            titleAlarmBtn.isHidden = true
        } else if (chainType! == ChainType.RIZON_TEST) {
            titleChainImg.image = UIImage(named: "testnetRizon")
            titleChainName.text = "(Rizon Testnet)"
            titleAlarmBtn.isHidden = true
        } else if (chainType! == ChainType.MEDI_TEST) {
            titleChainImg.image = UIImage(named: "testnetMedibloc")
            titleChainName.text = "(Medi Testnet)"
            titleAlarmBtn.isHidden = true
        } else if (chainType! == ChainType.ALTHEA_TEST) {
            titleChainImg.image = UIImage(named: "testnetAlthea")
            titleChainName.text = "(Althea Testnet)"
            titleAlarmBtn.isHidden = true
        }
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            if settings.authorizationStatus == .authorized {
                DispatchQueue.main.async {
                    if (self.account?.account_push_alarm == true) {
                        self.titleAlarmBtn.setImage(UIImage(named: "notificationsIc"), for: .normal)
                    } else {
                        self.titleAlarmBtn.setImage(UIImage(named: "notificationsIcOff"), for: .normal)
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.titleAlarmBtn.setImage(UIImage(named: "notificationsIcOff"), for: .normal)
                }
            }
        }
    }
    
    func updateView() {
        self.onClassifyTokens()
        self.tokenTableView.reloadData()
        self.totalValue.attributedText = WUtils.dpAllAssetValueUserCurrency(chainType, totalValue.font)
    }
    
    @objc func onRequestFetch() {
        if (!mainTabVC.onFetchAccountData()) {
            self.refresher.endRefreshing()
        }
    }
    
    @objc func onFetchDone(_ notification: NSNotification) {
        self.mBalances = BaseData.instance.mBalances
        self.mBalances_gRPC = BaseData.instance.mMyBalances_gRPC
        
        self.updateView()
        self.refresher.endRefreshing()
    }
    
    @objc func onFetchPrice(_ notification: NSNotification) {
        self.updateView()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 9
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (section == SECTION_NATIVE_GRPC && mNative_gRPC.count == 0) { return 0 }
        else if (section == SECTION_IBC_AUTHED_GRPC && mIbcAuthed_gRPC.count == 0) { return 0 }
        else if (section == SECTION_OSMOSIS_POOL_GRPC && mOsmosisPool_gRPC.count == 0) { return 0 }
        else if (section == SECTION_SIF_ETHER_GRPC && mSifEther_gRPC.count == 0) { return 0 }
        else if (section == SECTION_IBC_UNKNOWN_GRPC && mIbcUnknown_gRPC.count == 0) { return 0 }
        else if (section == SECTION_UNKNOWN_GRPC && mUnKnown_gRPC.count == 0) { return 0 }
        
        else if (section == SECTION_NATIVE && mNative.count == 0) { return 0 }
        else if (section == SECTION_KAVA_BEP2 && mKavaBep2.count == 0) { return 0 }
        else if (section == SECTION_ETC && mEtc.count == 0) { return 0 }
        else if (section == SECTION_UNKNOWN && mUnKnown.count == 0) { return 0 }
        else { return 30 }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = CommonHeader(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        if (section == SECTION_NATIVE_GRPC) { view.headerTitleLabel.text = "Native Tokens"; view.headerCntLabel.text = String(self.mNative_gRPC.count) }
        else if (section == SECTION_IBC_AUTHED_GRPC) { view.headerTitleLabel.text = "IBC Tokens"; view.headerCntLabel.text = String(self.mIbcAuthed_gRPC.count) }
        else if (section == SECTION_OSMOSIS_POOL_GRPC) { view.headerTitleLabel.text = "POOL Tokens"; view.headerCntLabel.text = String(self.mOsmosisPool_gRPC.count)}
        else if (section == SECTION_SIF_ETHER_GRPC) { view.headerTitleLabel.text = "Ether Bridged Tokens"; view.headerCntLabel.text = String(self.mSifEther_gRPC.count) }
        else if (section == SECTION_IBC_UNKNOWN_GRPC) { view.headerTitleLabel.text = "Unknown IBC Tokens"; view.headerCntLabel.text = String(self.mIbcUnknown_gRPC.count) }
        else if (section == SECTION_UNKNOWN_GRPC) { view.headerTitleLabel.text = "Unknown Tokens"; view.headerCntLabel.text = String(self.mUnKnown_gRPC.count) }
        
        else if (section == SECTION_NATIVE) { view.headerTitleLabel.text = "Native Tokens"; view.headerCntLabel.text = String(self.mNative.count) }
        else if (section == SECTION_KAVA_BEP2) { view.headerTitleLabel.text = "BEP2 Tokens"; view.headerCntLabel.text = String(self.mKavaBep2.count) }
        else if (section == SECTION_ETC) { view.headerTitleLabel.text = "Etc Tokens"; view.headerCntLabel.text = String(self.mEtc.count) }
        else if (section == SECTION_UNKNOWN) { view.headerTitleLabel.text = "Unknown Tokens"; view.headerCntLabel.text = String(self.mUnKnown.count) }
        else { view.headerTitleLabel.text = ""; view.headerCntLabel.text = "0" }
        return view
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == SECTION_NATIVE_GRPC) { return mNative_gRPC.count }
        else if (section == SECTION_IBC_AUTHED_GRPC) { return mIbcAuthed_gRPC.count }
        else if (section == SECTION_OSMOSIS_POOL_GRPC) { return mOsmosisPool_gRPC.count }
        else if (section == SECTION_SIF_ETHER_GRPC) { return mSifEther_gRPC.count }
        else if (section == SECTION_IBC_UNKNOWN_GRPC) { return mIbcUnknown_gRPC.count }
        else if (section == SECTION_UNKNOWN_GRPC) { return mUnKnown_gRPC.count }
        
        else if (section == SECTION_NATIVE) { return mNative.count }
        else if (section == SECTION_KAVA_BEP2) { return mKavaBep2.count }
        else if (section == SECTION_ETC) { return mEtc.count }
        else if (section == SECTION_UNKNOWN) { return mUnKnown.count }
        else { return 0 }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:"TokenCell") as? TokenCell
        if (indexPath.section == SECTION_NATIVE_GRPC) {
            onBindNativeToken_gRPC(cell, mNative_gRPC[indexPath.row])
            
        } else if (indexPath.section == SECTION_IBC_AUTHED_GRPC) {
            onBindIbcToken_gRPC(cell, mIbcAuthed_gRPC[indexPath.row])
            
        } else if (indexPath.section == SECTION_OSMOSIS_POOL_GRPC) {
            onBindOsmoPoolToken_gRPC(cell, mOsmosisPool_gRPC[indexPath.row])
            
        } else if (indexPath.section == SECTION_SIF_ETHER_GRPC) {
            onBindSifEtherToken_gRPC(cell, mSifEther_gRPC[indexPath.row])
            
        } else if (indexPath.section == SECTION_IBC_UNKNOWN_GRPC) {
            onBindIbcToken_gRPC(cell, mIbcUnknown_gRPC[indexPath.row])
            
        } else if (indexPath.section == SECTION_IBC_UNKNOWN_GRPC) {
            cell?.tokenSymbol.text = "IBC"
            
        } else if (indexPath.section == SECTION_UNKNOWN_GRPC) {
            cell?.tokenSymbol.text = mUnKnown_gRPC[indexPath.row].denom.uppercased()
        }
        
        else if (indexPath.section == SECTION_NATIVE) {
            onBindNativeToken(cell, mNative[indexPath.row])
            
        } else if (indexPath.section == SECTION_KAVA_BEP2) {
            onBindKavaBep2Token(cell, mKavaBep2[indexPath.row])
            
        } else if (indexPath.section == SECTION_ETC) {
            onBindEtcToken(cell, mEtc[indexPath.row])
            
        } else if (indexPath.section == SECTION_UNKNOWN) {
            cell?.tokenSymbol.text = mUnKnown[indexPath.row].balance_denom.uppercased()
            
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath.section == SECTION_NATIVE_GRPC) {
            if (mNative_gRPC[indexPath.row].denom == WUtils.getMainDenom(chainType)) {
                let sTokenDetailVC = StakingTokenDetailViewController(nibName: "StakingTokenDetailViewController", bundle: nil)
                sTokenDetailVC.hidesBottomBarWhenPushed = true
                self.navigationItem.title = ""
                self.navigationController?.pushViewController(sTokenDetailVC, animated: true)
            }
            
        } else if (indexPath.section == SECTION_IBC_AUTHED_GRPC) {
            
        } else if (indexPath.section == SECTION_OSMOSIS_POOL_GRPC) {
            
        } else if (indexPath.section == SECTION_SIF_ETHER_GRPC) {
            let nTokenDetailVC = NativeTokenDetailViewController(nibName: "NativeTokenDetailViewController", bundle: nil)
            nTokenDetailVC.hidesBottomBarWhenPushed = true
            nTokenDetailVC.denom = mSifEther_gRPC[indexPath.row].denom
            self.navigationItem.title = ""
            self.navigationController?.pushViewController(nTokenDetailVC, animated: true)
            
        } else if (indexPath.section == SECTION_UNKNOWN_GRPC) {
            
        }
        
        else if (indexPath.section == SECTION_NATIVE) {
            if (mNative[indexPath.row].balance_denom == WUtils.getMainDenom(chainType)) {
                let sTokenDetailVC = StakingTokenDetailViewController(nibName: "StakingTokenDetailViewController", bundle: nil)
                sTokenDetailVC.hidesBottomBarWhenPushed = true
                self.navigationItem.title = ""
                self.navigationController?.pushViewController(sTokenDetailVC, animated: true)

            } else {
                let nTokenDetailVC = NativeTokenDetailViewController(nibName: "NativeTokenDetailViewController", bundle: nil)
                nTokenDetailVC.hidesBottomBarWhenPushed = true
                nTokenDetailVC.denom = mNative[indexPath.row].balance_denom
                self.navigationItem.title = ""
                self.navigationController?.pushViewController(nTokenDetailVC, animated: true)
            }
            
        } else if (indexPath.section == SECTION_KAVA_BEP2) {
            let nTokenDetailVC = NativeTokenDetailViewController(nibName: "NativeTokenDetailViewController", bundle: nil)
            nTokenDetailVC.hidesBottomBarWhenPushed = true
            nTokenDetailVC.denom = mKavaBep2[indexPath.row].balance_denom
            self.navigationItem.title = ""
            self.navigationController?.pushViewController(nTokenDetailVC, animated: true)
            
        } else if (indexPath.section == SECTION_ETC) {
            if (chainType == ChainType.KAVA_MAIN || chainType == ChainType.BINANCE_MAIN || chainType == ChainType.OKEX_MAIN) {
                let nTokenDetailVC = NativeTokenDetailViewController(nibName: "NativeTokenDetailViewController", bundle: nil)
                nTokenDetailVC.hidesBottomBarWhenPushed = true
                nTokenDetailVC.denom = mEtc[indexPath.row].balance_denom
                self.navigationItem.title = ""
                self.navigationController?.pushViewController(nTokenDetailVC, animated: true)
            }
            
        } else if (indexPath.section == SECTION_UNKNOWN) {
            
        }
    }
    
    //bind native tokens with grpc
    func onBindNativeToken_gRPC(_ cell: TokenCell?, _ coin: Coin) {
        if (coin.denom == COSMOS_MAIN_DENOM) {
            cell?.tokenImg.image = UIImage(named: "atom_ic")
            cell?.tokenSymbol.text = "ATOM"
            cell?.tokenSymbol.textColor = COLOR_ATOM
            cell?.tokenTitle.text = "(" + coin.denom + ")"
            cell?.tokenDescription.text = "Cosmos Staking Token"
            
            let allAtom = WUtils.getAllMainAsset(COSMOS_MAIN_DENOM)
            cell?.tokenAmount.attributedText = WUtils.displayAmount2(allAtom.stringValue, cell!.tokenAmount.font, 6, 6)
            cell?.tokenValue.attributedText = WUtils.dpUserCurrencyValue(COSMOS_MAIN_DENOM, allAtom, 6, cell!.tokenValue.font)
            
        } else if (coin.denom == IRIS_MAIN_DENOM) {
            cell?.tokenImg.image = UIImage(named: "irisTokenImg")
            cell?.tokenSymbol.text = "IRIS"
            cell?.tokenSymbol.textColor = COLOR_IRIS
            cell?.tokenTitle.text = "(" + coin.denom + ")"
            cell?.tokenDescription.text = "Iris Staking Token"
            
            let allIris = WUtils.getAllMainAsset(IRIS_MAIN_DENOM)
            cell?.tokenAmount.attributedText = WUtils.displayAmount2(allIris.stringValue, cell!.tokenAmount.font, 6, 6)
            cell?.tokenValue.attributedText = WUtils.dpUserCurrencyValue(IRIS_MAIN_DENOM, allIris, 6, cell!.tokenValue.font)
            
        } else if (coin.denom == AKASH_MAIN_DENOM) {
            cell?.tokenImg.image = UIImage(named: "akashTokenImg")
            cell?.tokenSymbol.text = "AKT"
            cell?.tokenSymbol.textColor = COLOR_AKASH
            cell?.tokenTitle.text = "(" + coin.denom + ")"
            cell?.tokenDescription.text = "Akash Staking Token"
            
            let allAkt = WUtils.getAllMainAsset(AKASH_MAIN_DENOM)
            cell?.tokenAmount.attributedText = WUtils.displayAmount2(allAkt.stringValue, cell!.tokenAmount.font, 6, 6)
            cell?.tokenValue.attributedText = WUtils.dpUserCurrencyValue(AKASH_MAIN_DENOM, allAkt, 6, cell!.tokenValue.font)
            
        } else if (coin.denom == PERSIS_MAIN_DENOM) {
            cell?.tokenImg.image = UIImage(named: "tokenpersistence")
            cell?.tokenSymbol.text = "XPRT"
            cell?.tokenSymbol.textColor = COLOR_PERSIS
            cell?.tokenTitle.text = "(" + coin.denom + ")"
            cell?.tokenDescription.text = "Persistence Staking Token"
            
            let allPersis = WUtils.getAllMainAsset(PERSIS_MAIN_DENOM)
            cell?.tokenAmount.attributedText = WUtils.displayAmount2(allPersis.stringValue, cell!.tokenAmount.font, 6, 6)
            cell?.tokenValue.attributedText = WUtils.dpUserCurrencyValue(PERSIS_MAIN_DENOM, allPersis, 6, cell!.tokenValue.font)
            
        } else if (coin.denom == CRYPTO_MAIN_DENOM) {
            cell?.tokenImg.image = UIImage(named: "tokencrypto")
            cell?.tokenSymbol.text = "CRO"
            cell?.tokenSymbol.textColor = COLOR_CRYPTO
            cell?.tokenTitle.text = "(" + coin.denom + ")"
            cell?.tokenDescription.text = "Crypto.org Staking Token"
            
            let allCro = WUtils.getAllMainAsset(CRYPTO_MAIN_DENOM)
            cell?.tokenAmount.attributedText = WUtils.displayAmount2(allCro.stringValue, cell!.tokenAmount.font, 8, 6)
            cell?.tokenValue.attributedText = WUtils.dpUserCurrencyValue(CRYPTO_MAIN_DENOM, allCro, 8, cell!.tokenValue.font)
            
        } else if (coin.denom == SENTINEL_MAIN_DENOM) {
            cell?.tokenImg.image = UIImage(named: "tokensentinel")
            cell?.tokenSymbol.text = "DVPN"
            cell?.tokenSymbol.textColor = COLOR_SENTINEL
            cell?.tokenTitle.text = "(" + coin.denom + ")"
            cell?.tokenDescription.text = "Sentinel Staking Token"
            
            let allDvpn = WUtils.getAllMainAsset(SENTINEL_MAIN_DENOM)
            cell?.tokenAmount.attributedText = WUtils.displayAmount2(allDvpn.stringValue, cell!.tokenAmount.font, 6, 6)
            cell?.tokenValue.attributedText = WUtils.dpUserCurrencyValue(SENTINEL_MAIN_DENOM, allDvpn, 6, cell!.tokenValue.font)
            
        } else if (coin.denom == OSMOSIS_MAIN_DENOM) {
            cell?.tokenImg.image = UIImage(named: "tokenOsmosis")
            cell?.tokenSymbol.text = "OSMO"
            cell?.tokenSymbol.textColor = COLOR_OSMOSIS
            cell?.tokenTitle.text = "(" + coin.denom + ")"
            cell?.tokenDescription.text = "Osmosis Staking Token"
            
            let allOsmos = WUtils.getAllMainAsset(OSMOSIS_MAIN_DENOM)
            cell?.tokenAmount.attributedText = WUtils.displayAmount2(allOsmos.stringValue, cell!.tokenAmount.font, 6, 6)
            cell?.tokenValue.attributedText = WUtils.dpUserCurrencyValue(OSMOSIS_MAIN_DENOM, allOsmos, 6, cell!.tokenValue.font)
            
        } else if (coin.denom == OSMOSIS_ION_DENOM) {
            cell?.tokenImg.image = UIImage(named: "tokenIon")
            cell?.tokenSymbol.text = "ION"
            cell?.tokenSymbol.textColor = COLOR_ION
            cell?.tokenTitle.text = "(" + coin.denom + ")"
            cell?.tokenDescription.text = "Ion Token"
            cell?.tokenAmount.attributedText = WUtils.displayAmount2(coin.amount, cell!.tokenAmount.font, 6, 6)
            cell?.tokenValue.attributedText = WUtils.dpUserCurrencyValue(OSMOSIS_ION_DENOM, BaseData.instance.getAvailableAmount_gRPC(OSMOSIS_ION_DENOM), 6, cell!.tokenValue.font)
            
        } else if (coin.denom == IOV_MAIN_DENOM) {
            cell?.tokenImg.image = UIImage(named: "iovTokenImg")
            cell?.tokenSymbol.text = "IOV"
            cell?.tokenSymbol.textColor = COLOR_IOV
            cell?.tokenTitle.text = "(" + coin.denom + ")"
            cell?.tokenDescription.text = "Starname Staking Token"
            
            let allIov = WUtils.getAllMainAsset(IOV_MAIN_DENOM)
            cell?.tokenAmount.attributedText = WUtils.displayAmount2(allIov.stringValue, cell!.tokenAmount.font, 6, 6)
            cell?.tokenValue.attributedText = WUtils.dpUserCurrencyValue(IOV_MAIN_DENOM, allIov, 6, cell!.tokenValue.font)
            
        } else if (coin.denom == SIF_MAIN_DENOM) {
            cell?.tokenImg.image = UIImage(named: "tokensifchain")
            cell?.tokenSymbol.text = "ROWAN"
            cell?.tokenSymbol.textColor = COLOR_SIF
            cell?.tokenTitle.text = "(" + coin.denom + ")"
            cell?.tokenDescription.text = "Sifchain Staking Token"
            
            let allSif = WUtils.getAllMainAsset(SIF_MAIN_DENOM)
            cell?.tokenAmount.attributedText = WUtils.displayAmount2(allSif.stringValue, cell!.tokenAmount.font, 18, 6)
            cell?.tokenValue.attributedText = WUtils.dpUserCurrencyValue(SIF_MAIN_DENOM, allSif, 18, cell!.tokenValue.font)
            
        } else if (coin.denom == RIZON_MAIN_DENOM) {
            cell?.tokenImg.image = UIImage(named: "tokenRizon")
            cell?.tokenSymbol.text = "ATOLO"
            cell?.tokenSymbol.textColor = COLOR_RIZON
            cell?.tokenTitle.text = "(" + coin.denom + ")"
            cell?.tokenDescription.text = "Rizon Staking Token"
            
            let allCro = WUtils.getAllMainAsset(RIZON_MAIN_DENOM)
            cell?.tokenAmount.attributedText = WUtils.displayAmount2(allCro.stringValue, cell!.tokenAmount.font, 6, 6)
            cell?.tokenValue.attributedText = WUtils.dpUserCurrencyValue(RIZON_MAIN_DENOM, allCro, 6, cell!.tokenValue.font)
            
        } else if (coin.denom == ALTHEA_MAIN_DENOM) {
            cell?.tokenImg.image = UIImage(named: "tokenAlthea")
            cell?.tokenSymbol.text = "ALTG"
            cell?.tokenSymbol.textColor = COLOR_ALTHEA
            cell?.tokenTitle.text = "(" + coin.denom + ")"
            cell?.tokenDescription.text = "Althea Staking Token"
            
            let allAlthea = WUtils.getAllMainAsset(ALTHEA_MAIN_DENOM)
            cell?.tokenAmount.attributedText = WUtils.displayAmount2(allAlthea.stringValue, cell!.tokenAmount.font, 6, 6)
            cell?.tokenValue.attributedText = WUtils.dpUserCurrencyValue(ALTHEA_MAIN_DENOM, allAlthea, 6, cell!.tokenValue.font)
            
        } else if (coin.denom == MEDI_MAIN_DENOM) {
            cell?.tokenImg.image = UIImage(named: "tokenmedibloc")
            cell?.tokenSymbol.text = "MED"
            cell?.tokenSymbol.textColor = COLOR_MEDI
            cell?.tokenTitle.text = "(" + coin.denom + ")"
            cell?.tokenDescription.text = "Mediblock Staking Token"

            let allMed = WUtils.getAllMainAsset(MEDI_MAIN_DENOM)
            cell?.tokenAmount.attributedText = WUtils.displayAmount2(allMed.stringValue, cell!.tokenAmount.font, 6, 6)
            cell?.tokenValue.attributedText = WUtils.dpUserCurrencyValue(MEDI_MAIN_DENOM, allMed, 6, cell!.tokenValue.font)
        }
        
        else if (coin.denom == COSMOS_TEST_DENOM) {
            cell?.tokenImg.image = UIImage(named: "atom_ic")
            cell?.tokenSymbol.text = "MUON"
            cell?.tokenSymbol.textColor = COLOR_ATOM
            cell?.tokenTitle.text = "(" + coin.denom + ")"
            cell?.tokenDescription.text = "Stargate Staking Token"
            let allAtom = WUtils.getAllMainAsset(COSMOS_TEST_DENOM)
            
            cell?.tokenAmount.attributedText = WUtils.displayAmount2(allAtom.stringValue, cell!.tokenAmount.font, 6, 6)
            cell?.tokenValue.attributedText = WUtils.dpUserCurrencyValue(COSMOS_TEST_DENOM, allAtom, 6, cell!.tokenValue.font)
            
        } else if (coin.denom == IRIS_TEST_DENOM) {
            cell?.tokenImg.image = UIImage(named: "irisTokenImg")
            cell?.tokenSymbol.text = "BIF"
            cell?.tokenSymbol.textColor = COLOR_IRIS
            cell?.tokenTitle.text = "(" + coin.denom + ")"
            cell?.tokenDescription.text = "Bifrost Staking Token"
            
            let allIris = WUtils.getAllMainAsset(IRIS_TEST_DENOM)
            cell?.tokenAmount.attributedText = WUtils.displayAmount2(allIris.stringValue, cell!.tokenAmount.font, 6, 6)
            cell?.tokenValue.attributedText = WUtils.dpUserCurrencyValue(IRIS_TEST_DENOM, allIris, 6, cell!.tokenValue.font)
        }
    }
    
    //bind ibc tokens with grpc
    func onBindIbcToken_gRPC(_ cell: TokenCell?, _ coin: Coin) {
        cell?.tokenSymbol.textColor = UIColor.white
        guard let ibcToken = BaseData.instance.getIbcToken(coin.getIbcHash()) else {
            cell?.tokenImg.image = UIImage(named: "tokenDefaultIbc")
            cell?.tokenSymbol.text = "UnKnown"
            cell?.tokenTitle.text = ""
            cell?.tokenDescription.text = coin.denom
            cell?.tokenAmount.attributedText = WUtils.displayAmount2(coin.amount, cell!.tokenAmount.font, 6, 6)
            cell?.tokenValue.attributedText = WUtils.dpUserCurrencyValue(coin.denom, NSDecimalNumber.init(string: coin.amount), 6, cell!.tokenValue.font)
            return
        }
        if (ibcToken.auth == true) {
            cell?.tokenImg.af_setImage(withURL: URL(string: ibcToken.moniker!)!)
            cell?.tokenSymbol.text = ibcToken.display_denom?.uppercased()
            cell?.tokenTitle.text = "(" + ibcToken.base_denom! + ")"
            cell?.tokenDescription.text = coin.denom
            cell?.tokenAmount.attributedText = WUtils.displayAmount2(coin.amount, cell!.tokenAmount.font, ibcToken.decimal!, 6)
            cell?.tokenValue.attributedText = WUtils.dpUserCurrencyValue(ibcToken.base_denom!, NSDecimalNumber.init(string: coin.amount), ibcToken.decimal!, cell!.tokenValue.font)
            
        } else {
            cell?.tokenImg.image = UIImage(named: "tokenDefaultIbc")
            cell?.tokenSymbol.text = "UnKnown"
            cell?.tokenTitle.text = "(" + ibcToken.base_denom! + ")"
            cell?.tokenDescription.text = coin.denom
            cell?.tokenAmount.attributedText = WUtils.displayAmount2(coin.amount, cell!.tokenAmount.font, 6, 6)
            cell?.tokenValue.attributedText = WUtils.dpUserCurrencyValue(coin.denom, NSDecimalNumber.init(string: coin.amount), 6, cell!.tokenValue.font)
        }
    }
    
    //bind osmosis Pool tokens with grpc
    func onBindOsmoPoolToken_gRPC(_ cell: TokenCell?, _ coin: Coin) {
        cell?.tokenImg.image = UIImage(named: "tokenPool")
        cell?.tokenSymbol.text = coin.isOsmosisAmmDpDenom()
        cell?.tokenSymbol.textColor = UIColor.white
        cell?.tokenTitle.text = ""
        cell?.tokenDescription.text = coin.denom
        cell?.tokenAmount.attributedText = WUtils.displayAmount2(coin.amount, cell!.tokenAmount.font, 18, 6)
        cell?.tokenValue.attributedText = WUtils.dpUserCurrencyValue(coin.denom, NSDecimalNumber.init(string: coin.amount), 18, cell!.tokenValue.font)
    }
    
    //bind Erc on SifChain with grpc
    func onBindSifEtherToken_gRPC(_ cell: TokenCell?, _ coin: Coin) {
        cell?.tokenImg.af_setImage(withURL: URL(string: SIF_COIN_IMG_URL + coin.denom + ".png")!)
        cell?.tokenSymbol.text = coin.denom.substring(from: 1).uppercased()
        cell?.tokenSymbol.textColor = UIColor.white
        cell?.tokenTitle.text = "(" + coin.denom + ")"
        cell?.tokenDescription.text = coin.denom.substring(from: 1).uppercased() + " on Sifchain"
        
        let available = BaseData.instance.getAvailableAmount_gRPC(coin.denom)
        let decimal = WUtils.getSifCoinDecimal(coin.denom)
        cell?.tokenAmount.attributedText = WUtils.displayAmount2(available.stringValue, cell!.tokenAmount.font!, decimal, 6)
        cell?.tokenValue.attributedText = WUtils.dpUserCurrencyValue(coin.denom.substring(from: 1), available, decimal, cell!.tokenValue.font)
    }
    
    
    //bind native tokens
    func onBindNativeToken(_ cell: TokenCell?, _ balance: Balance) {
        if (balance.balance_denom == BNB_MAIN_DENOM) {
            if let bnbToken = WUtils.getBnbToken(BNB_MAIN_DENOM) {
                cell?.tokenImg.image = UIImage(named: "bnbTokenImg")
                cell?.tokenSymbol.text = bnbToken.original_symbol.uppercased()
                cell?.tokenSymbol.textColor = COLOR_BNB
                cell?.tokenTitle.text = "(" + bnbToken.symbol + ")"
                cell?.tokenDescription.text = bnbToken.name
                
                let amount = WUtils.getAllBnbToken(BNB_MAIN_DENOM)
                cell?.tokenAmount.attributedText = WUtils.displayAmount2(amount.stringValue, cell!.tokenAmount.font, 0, 6)
                cell?.tokenValue.attributedText = WUtils.dpUserCurrencyValue(BNB_MAIN_DENOM, amount, 0, cell!.tokenValue.font)
            }
            
        } else if (balance.balance_denom == KAVA_MAIN_DENOM) {
            cell?.tokenImg.image = UIImage(named: "kavaTokenImg")
            cell?.tokenSymbol.text = "KAVA"
            cell?.tokenSymbol.textColor = COLOR_KAVA
            cell?.tokenTitle.text = "(" + balance.balance_denom + ")"
            cell?.tokenDescription.text = "Kava Staking Token"
            
            let totalKava = WUtils.getAllMainAssetOld(KAVA_MAIN_DENOM)
            cell?.tokenAmount.attributedText = WUtils.displayAmount2(totalKava.stringValue, cell!.tokenAmount.font!, 6, 6)
            cell?.tokenValue.attributedText = WUtils.dpUserCurrencyValue(KAVA_MAIN_DENOM, totalKava, 6, cell!.tokenValue.font)
            
        } else if (balance.balance_denom == KAVA_HARD_DENOM) {
            cell?.tokenImg.image = UIImage(named: "tokenhard")
            cell?.tokenSymbol.text = "HARD"
            cell?.tokenSymbol.textColor = COLOR_HARD
            cell?.tokenTitle.text = "(" + balance.balance_denom + ")"
            cell?.tokenDescription.text = "HardPool Gov. Token"
            
            let totalTokenAmount = WUtils.getKavaTokenAll(balance.balance_denom, mBalances)
            let convertedKavaAmount = WUtils.convertTokenToKava(balance.balance_denom)
            cell?.tokenAmount.attributedText = WUtils.displayAmount2(totalTokenAmount.stringValue, cell!.tokenAmount.font!, 6, 6)
            cell?.tokenValue.attributedText = WUtils.dpUserCurrencyValue(KAVA_MAIN_DENOM, convertedKavaAmount, 6, cell!.tokenValue.font)
            
        } else if (balance.balance_denom == KAVA_USDX_DENOM) {
            cell?.tokenImg.af_setImage(withURL: URL(string: KAVA_COIN_IMG_URL + KAVA_USDX_DENOM + ".png")!)
            cell?.tokenSymbol.text = KAVA_USDX_DENOM.uppercased()
            cell?.tokenSymbol.textColor = UIColor.white
            cell?.tokenTitle.text = "(" + KAVA_USDX_DENOM + ")"
            cell?.tokenDescription.text = "USD Stable Asset"
            
            let totalTokenAmount = WUtils.getKavaTokenAll(balance.balance_denom, mBalances)
            let convertedKavaAmount = WUtils.convertTokenToKava(balance.balance_denom)
            cell?.tokenAmount.attributedText = WUtils.displayAmount2(totalTokenAmount.stringValue, cell!.tokenAmount.font!, 6, 6)
            cell?.tokenValue.attributedText = WUtils.dpUserCurrencyValue(KAVA_MAIN_DENOM, convertedKavaAmount, 6, cell!.tokenValue.font)
            
        } else if (balance.balance_denom == OKEX_MAIN_DENOM) {
            if let okToken = WUtils.getOkToken(OKEX_MAIN_DENOM) {
                cell?.tokenImg.image = UIImage(named: "okexTokenImg")
                cell?.tokenSymbol.text = okToken.original_symbol!.uppercased()
                cell?.tokenSymbol.textColor = COLOR_OK
                cell?.tokenTitle.text = "(" + okToken.symbol! + ")"
                cell?.tokenDescription.text = okToken.description
                
                let tokenAmount = WUtils.getAllExToken(OKEX_MAIN_DENOM)
                cell?.tokenAmount.attributedText = WUtils.displayAmount2(tokenAmount.stringValue, cell!.tokenAmount.font, 0, 6)
                cell?.tokenValue.attributedText = WUtils.dpUserCurrencyValue(OKEX_MAIN_DENOM, tokenAmount, 0, cell!.tokenValue.font)
            }
            
        } else if (balance.balance_denom == SECRET_MAIN_DENOM) {
            cell?.tokenImg.image = UIImage(named: "secretTokenImg")
            cell?.tokenSymbol.text = "SCRT"
            cell?.tokenSymbol.textColor = COLOR_SECRET
            cell?.tokenTitle.text = "(" + balance.balance_denom + ")"
            cell?.tokenDescription.text = "Secret Staking Token"
            
            let allSecret = WUtils.getAllMainAssetOld(SECRET_MAIN_DENOM)
            cell?.tokenAmount.attributedText = WUtils.displayAmount2(allSecret.stringValue, cell!.tokenAmount.font, 6, 6)
            cell?.tokenValue.attributedText = WUtils.dpUserCurrencyValue(SECRET_MAIN_DENOM, allSecret, 6, cell!.tokenValue.font)
            
        } else if (balance.balance_denom == CERTIK_MAIN_DENOM) {
            cell?.tokenImg.image = UIImage(named: "certikTokenImg")
            cell?.tokenSymbol.text = "CTK"
            cell?.tokenSymbol.textColor = COLOR_CERTIK
            cell?.tokenTitle.text = "(" + balance.balance_denom + ")"
            cell?.tokenDescription.text = "Certik Staking Token"
            
            let allCtk = WUtils.getAllMainAssetOld(CERTIK_MAIN_DENOM)
            cell?.tokenAmount.attributedText = WUtils.displayAmount2(allCtk.stringValue, cell!.tokenAmount.font, 6, 6)
            cell?.tokenValue.attributedText = WUtils.dpUserCurrencyValue(CERTIK_MAIN_DENOM, allCtk, 6, cell!.tokenValue.font)
            
        } else if (balance.balance_denom == FETCH_MAIN_DENOM) {
            cell?.tokenImg.image = UIImage(named: "tokenfetchai")
            cell?.tokenSymbol.text = "FET"
            cell?.tokenSymbol.textColor = COLOR_FETCH
            cell?.tokenTitle.text = "(" + balance.balance_denom + ")"
            cell?.tokenDescription.text = "Fetch.ai Staking Token"
            
            let allFet = WUtils.getAllMainAssetOld(FETCH_MAIN_DENOM)
            cell?.tokenAmount.attributedText = WUtils.displayAmount2(allFet.stringValue, cell!.tokenAmount.font, 18, 6)
            cell?.tokenValue.attributedText = WUtils.dpUserCurrencyValue(FETCH_MAIN_DENOM, allFet, 18, cell!.tokenValue.font)
            
        } else if (balance.balance_denom == KI_MAIN_DENOM) {
            cell?.tokenImg.image = UIImage(named: "tokenKifoundation")
            cell?.tokenSymbol.text = "XKI"
            cell?.tokenSymbol.textColor = COLOR_KI
            cell?.tokenTitle.text = "(" + balance.balance_denom + ")"
            cell?.tokenDescription.text = "KiChain Staking Token"
            
            let allKi = WUtils.getAllMainAssetOld(KI_MAIN_DENOM)
            cell?.tokenAmount.attributedText = WUtils.displayAmount2(allKi.stringValue, cell!.tokenAmount.font, 6, 6)
            cell?.tokenValue.attributedText = WUtils.dpUserCurrencyValue(KI_MAIN_DENOM, allKi, 6, cell!.tokenValue.font)
            
        } else if (balance.balance_denom == BAND_MAIN_DENOM) {
            cell?.tokenImg.image = UIImage(named: "tokenBand")
            cell?.tokenSymbol.text = "BAND"
            cell?.tokenSymbol.textColor = COLOR_BAND
            cell?.tokenTitle.text = "(" + balance.balance_denom + ")"
            cell?.tokenDescription.text = "Band Staking Token"
            
            let allBand = WUtils.getAllMainAssetOld(BAND_MAIN_DENOM)
            cell?.tokenAmount.attributedText = WUtils.displayAmount2(allBand.stringValue, cell!.tokenAmount.font, 6, 6)
            cell?.tokenValue.attributedText = WUtils.dpUserCurrencyValue(BAND_MAIN_DENOM, allBand, 6, cell!.tokenValue.font)
        }
    }
    
    //bind kava bep2 tokens
    func onBindKavaBep2Token(_ cell: TokenCell?, _ balance: Balance) {
        cell?.tokenImg.af_setImage(withURL: URL(string: KAVA_COIN_IMG_URL + balance.balance_denom + ".png")!)
        cell?.tokenSymbol.text = balance.balance_denom.uppercased()
        cell?.tokenSymbol.textColor = UIColor.white
        cell?.tokenTitle.text = "(" + balance.balance_denom + ")"
        cell?.tokenDescription.text = balance.balance_denom.uppercased() + " on Kava Chain"
        
        let totalTokenAmount = WUtils.getKavaTokenAll(balance.balance_denom, mBalances)
        let convertedKavaAmount = WUtils.convertTokenToKava(balance.balance_denom)
        cell?.tokenAmount.attributedText = WUtils.displayAmount2(totalTokenAmount.stringValue, cell!.tokenAmount.font!, WUtils.getKavaCoinDecimal(balance.balance_denom), 6)
        cell?.tokenValue.attributedText = WUtils.dpUserCurrencyValue(KAVA_MAIN_DENOM, convertedKavaAmount, 6, cell!.tokenValue.font)
    }
    
    //bind Etc tokens (kava, binance, okex)
    func onBindEtcToken(_ cell: TokenCell?, _ balance: Balance) {
        if (chainType == ChainType.KAVA_MAIN || balance.balance_denom == "btch") {
            cell?.tokenImg.af_setImage(withURL: URL(string: KAVA_COIN_IMG_URL + balance.balance_denom + ".png")!)
            cell?.tokenSymbol.text = balance.balance_denom.uppercased()
            cell?.tokenSymbol.textColor = UIColor.white
            cell?.tokenTitle.text = "(" + balance.balance_denom + ")"
            cell?.tokenDescription.text = balance.balance_denom.uppercased() + " on Kava Chain"

            let totalTokenAmount = WUtils.getKavaTokenAll(balance.balance_denom, mBalances)
            let convertedKavaAmount = WUtils.convertTokenToKava(balance.balance_denom)
            cell?.tokenAmount.attributedText = WUtils.displayAmount2(totalTokenAmount.stringValue, cell!.tokenAmount.font!, WUtils.getKavaCoinDecimal(balance.balance_denom), 6)
            cell?.tokenValue.attributedText = WUtils.dpUserCurrencyValue(KAVA_MAIN_DENOM, convertedKavaAmount, 6, cell!.tokenValue.font)

        } else if (chainType == ChainType.BINANCE_MAIN || chainType == ChainType.BINANCE_TEST) {
            if let bnbToken = WUtils.getBnbToken(balance.balance_denom) {
                cell?.tokenImg.af_setImage(withURL: URL(string: TOKEN_IMG_URL + bnbToken.original_symbol + ".png")!)
                cell?.tokenSymbol.text = bnbToken.original_symbol.uppercased()
                cell?.tokenSymbol.textColor = .white
                cell?.tokenTitle.text = "(" + bnbToken.symbol + ")"
                cell?.tokenDescription.text = bnbToken.name
                
                let tokenAmount = WUtils.getAllBnbToken(balance.balance_denom)
                let convertAmount = WUtils.getBnbConvertAmount(balance.balance_denom)
                cell?.tokenAmount.attributedText = WUtils.displayAmount2(tokenAmount.stringValue, cell!.tokenAmount.font, 0, 6)
                cell?.tokenValue.attributedText = WUtils.dpUserCurrencyValue(BNB_MAIN_DENOM, convertAmount, 0, cell!.tokenValue.font)
            }
            
        }  else if (chainType == ChainType.OKEX_MAIN || chainType == ChainType.OKEX_TEST) {
            if let okToken = WUtils.getOkToken(balance.balance_denom) {
                cell?.tokenImg.af_setImage(withURL: URL(string: OKEX_COIN_IMG_URL + okToken.original_symbol! + ".png")!)
                cell?.tokenSymbol.text = okToken.original_symbol?.uppercased()
                cell?.tokenSymbol.textColor = .white
                cell?.tokenTitle.text = "(" + okToken.symbol! + ")"
                cell?.tokenDescription.text = okToken.description
                
                let tokenAmount = WUtils.getAllExToken(balance.balance_denom)
                let convertedAmount = WUtils.convertTokenToOkt(balance.balance_denom)
                cell?.tokenAmount.attributedText = WUtils.displayAmount2(tokenAmount.stringValue, cell!.tokenAmount.font, 0, 6)
                cell?.tokenValue.attributedText = WUtils.dpUserCurrencyValue(OKEX_MAIN_DENOM, convertedAmount, 0, cell!.tokenValue.font)
            }
        }
        
    }
    
    
    func onClassifyTokens() {
        mNative_gRPC.removeAll()
        mIbcAuthed_gRPC.removeAll()
        mOsmosisPool_gRPC.removeAll()
        mSifEther_gRPC.removeAll()
        mIbcUnknown_gRPC.removeAll()
        
        self.mBalances_gRPC.forEach { balance_gRPC in
            if (WUtils.getMainDenom(chainType) == balance_gRPC.denom) {
                mNative_gRPC.append(balance_gRPC)
                
            } else if (balance_gRPC.isIbc()) {
                guard let ibcToken = BaseData.instance.getIbcToken(balance_gRPC.getIbcHash()) else {
                    mIbcUnknown_gRPC.append(balance_gRPC)
                    return
                }
                if (ibcToken.auth == true) { mIbcAuthed_gRPC.append(balance_gRPC) }
                else { mIbcUnknown_gRPC.append(balance_gRPC) }
                
            } else if (chainType == ChainType.OSMOSIS_MAIN && balance_gRPC.isOsmosisAmm()) {
                mOsmosisPool_gRPC.append(balance_gRPC)
                
            } else if (chainType == ChainType.OSMOSIS_MAIN && balance_gRPC.denom == OSMOSIS_ION_DENOM) {
                mNative_gRPC.append(balance_gRPC)
                
            } else if (chainType == ChainType.SIF_MAIN && balance_gRPC.denom.starts(with: "c")) {
                mSifEther_gRPC.append(balance_gRPC)
                
            } else {
                mUnKnown_gRPC.append(balance_gRPC)
            }
        }
        
        mNative.removeAll()
        mKavaBep2.removeAll()
        mEtc.removeAll()
        mUnKnown.removeAll()
        self.mBalances.forEach { balance in
            if (WUtils.getMainDenom(chainType) == balance.balance_denom) {
                mNative.append(balance)
                
            } else if (chainType == ChainType.KAVA_MAIN || chainType == ChainType.KAVA_TEST) {
                if (balance.balance_denom == KAVA_HARD_DENOM || balance.balance_denom == KAVA_USDX_DENOM) {
                    mNative.append(balance)
                    
                } else if (balance.balance_denom == TOKEN_HTLC_KAVA_BNB || balance.balance_denom == TOKEN_HTLC_KAVA_BTCB ||
                            balance.balance_denom == TOKEN_HTLC_KAVA_XRPB || balance.balance_denom == TOKEN_HTLC_KAVA_BUSD) {
                    mKavaBep2.append(balance)
                    
                } else if (balance.balance_denom == "btch") {
                    mEtc.append(balance)
                }
                
            } else if (chainType == ChainType.BINANCE_MAIN || chainType == ChainType.BINANCE_TEST) {
                mEtc.append(balance)
                
            } else if (chainType == ChainType.OKEX_MAIN || chainType == ChainType.OKEX_TEST) {
                mEtc.append(balance)
                
            } else {
                mUnKnown.append(balance)
                
            }
        }
        
        
        mNative_gRPC.sort {
            if ($0.denom == WUtils.getMainDenom(chainType)) { return true }
            if ($1.denom == WUtils.getMainDenom(chainType)) { return false }
            return false
        }
        mOsmosisPool_gRPC.sort {
            return $0.osmosisAmmPoolId() < $1.osmosisAmmPoolId()
        }
        mNative.sort {
            if ($0.balance_denom == WUtils.getMainDenom(chainType)) { return true }
            if ($1.balance_denom == WUtils.getMainDenom(chainType)) { return false }
            if (chainType == ChainType.KAVA_MAIN || chainType == ChainType.KAVA_TEST) {
                if ($0.balance_denom == KAVA_HARD_DENOM) { return true }
                if ($1.balance_denom == KAVA_HARD_DENOM) { return false }
            }
            return false
        }
        mEtc.sort {
            if (chainType == ChainType.OKEX_MAIN) {
                if ($0.balance_denom == "okb-c4d") { return true }
                if ($1.balance_denom == "okb-c4d") { return false }
            }
            return false
        }
    }
    
    @IBAction func onClickSwitchAccount(_ sender: Any) {
        self.mainTabVC.onShowAccountSwicth()
    }
    
    @IBAction func onClickExplorer(_ sender: UIButton) {
        let link = WUtils.getAccountExplorer(chainType!, account!.account_address)
        guard let url = URL(string: link) else { return }
        self.onShowSafariWeb(url)
    }
    
    @IBAction func onClickAlaram(_ sender: UIButton) {
        if (sender.imageView?.image == UIImage(named: "notificationsIcOff")) {
            UNUserNotificationCenter.current().getNotificationSettings { (settings) in
                if settings.authorizationStatus == .authorized {
                    DispatchQueue.main.async {
                        self.showWaittingAlert()
                        self.onToggleAlarm(self.account!) { (success) in
                            self.mainTabVC.onUpdateAccountDB()
                            self.updateTitle()
                            self.dismissAlertController()
                        }
                    }
                    
                } else {
                    let alertController = UIAlertController(title: NSLocalizedString("permission_push_title", comment: ""), message: NSLocalizedString("permission_push_msg", comment: ""), preferredStyle: .alert)
                    let settingsAction = UIAlertAction(title: NSLocalizedString("settings", comment: ""), style: .default) { (_) -> Void in
                        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                            return
                        }
                        if UIApplication.shared.canOpenURL(settingsUrl) {
                            UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                            })
                        }
                    }
                    let cancelAction = UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .default, handler: nil)
                    alertController.addAction(cancelAction)
                    alertController.addAction(settingsAction)
                    DispatchQueue.main.async {
                        self.present(alertController, animated: true, completion: nil)
                    }
                }
            }
        } else {
            DispatchQueue.main.async {
                self.showWaittingAlert()
                self.onToggleAlarm(self.account!) { (success) in
                    self.mainTabVC.onUpdateAccountDB()
                    self.updateTitle()
                    self.dismissAlertController()
                }
            }
        }
    }
    
    @objc func onClickActionShare() {
        var nickName:String?
        if (account?.account_nick_name == "") {
            nickName = NSLocalizedString("wallet_dash", comment: "") + String(account!.account_id)
        } else {
            nickName = account?.account_nick_name
        }
        var address = account!.account_address
        if (chainType == ChainType.OKEX_MAIN || chainType == ChainType.OKEX_TEST) {
            address = WKey.convertAddressOkexToEth(address)
        }
        self.shareAddress(address, nickName!)
    }
}
