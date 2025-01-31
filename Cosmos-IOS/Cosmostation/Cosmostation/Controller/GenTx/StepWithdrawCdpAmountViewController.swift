//
//  StepWithdrawCdpAmountViewController.swift
//  Cosmostation
//
//  Created by 정용주 on 2020/03/31.
//  Copyright © 2020 wannabit. All rights reserved.
//

import UIKit
import Alamofire

class StepWithdrawCdpAmountViewController: BaseViewController, UITextFieldDelegate, SBCardPopupDelegate{
    
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var btnNext: UIButton!
    @IBOutlet weak var loadingImg: LoadingImageView!
    
    @IBOutlet weak var cDenomImg: UIImageView!
    @IBOutlet weak var cDenomLabel: UILabel!
    @IBOutlet weak var cAmountInput: AmountInputTextField!
    @IBOutlet weak var cAvailabeMaxLabel: UILabel!
    @IBOutlet weak var cAvailableDenom: UILabel!

    @IBOutlet weak var beforeSafeTxt: UILabel!
    @IBOutlet weak var beforeSafeRate: UILabel!
    @IBOutlet weak var afterSafeTxt: UILabel!
    @IBOutlet weak var afterSafeRate: UILabel!
    
    var pageHolderVC: StepGenTxViewController!
    
    var mCDenom: String = ""
    var mPDenom: String = ""
    var cDpDecimal:Int16 = 6
    var pDpDecimal:Int16 = 6
    var mMarketID: String = ""
    
    var mCollateralParamType: String?
    var mCollateralParam: CollateralParam?
    var mCdpParam: CdpParam?
    var myCdp: MyCdp?
    var mSelfDepositAmount: NSDecimalNumber = NSDecimalNumber.zero
    var mPrice: KavaPriceFeedPrice?
    
    var currentPrice: NSDecimalNumber = NSDecimalNumber.zero
    var beforeLiquidationPrice: NSDecimalNumber = NSDecimalNumber.zero
    var afterLiquidationPrice: NSDecimalNumber = NSDecimalNumber.zero
    var beforeRiskRate: NSDecimalNumber = NSDecimalNumber.zero
    var afterRiskRate: NSDecimalNumber = NSDecimalNumber.zero
    
    var cMaxWithdrawableAmount: NSDecimalNumber = NSDecimalNumber.zero
    var toCAmount: NSDecimalNumber = NSDecimalNumber.zero
    var sumCAmount: NSDecimalNumber = NSDecimalNumber.zero

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.account = BaseData.instance.selectAccountById(id: BaseData.instance.getRecentAccountId())
        self.chainType = WUtils.getChainType(account!.account_base_chain)
        
        pageHolderVC = self.parent as? StepGenTxViewController
        mCollateralParamType = pageHolderVC.mCollateralParamType
        mCdpParam = BaseData.instance.mCdpParam
        mCollateralParam = mCdpParam?.getCollateralParamByType(pageHolderVC.mCollateralParamType!)
        mMarketID = mCollateralParam!.liquidation_market_id!
        
        self.loadingImg.onStartAnimation()
        self.onFetchCdpData()
        
        cAmountInput.delegate = self
    }
    
    override func enableUserInteraction() {
        self.btnCancel.isUserInteractionEnabled = true
        self.btnNext.isUserInteractionEnabled = true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        if (text.contains(".") && string.contains(".") && range.length == 0) { return false }
        if (text.count == 0 && string.starts(with: ".")) { return false }
        if (text.contains(",") && string.contains(",") && range.length == 0) { return false }
        if (text.count == 0 && string.starts(with: ",")) { return false }
        if let index = text.range(of: ".")?.upperBound {
            if(text.substring(from: index).count > (cDpDecimal - 1) && range.length == 0) { return false }
        }
        if let index = text.range(of: ",")?.upperBound {
            if(text.substring(from: index).count > (cDpDecimal - 1) && range.length == 0) { return false }
        }
        return true
    }
    
    @IBAction func AmountChanged(_ sender: AmountInputTextField) {
        onUpdateNextBtn()
        guard let text = sender.text?.trimmingCharacters(in: .whitespaces) else {
            sender.layer.borderColor = UIColor.init(hexString: "f31963").cgColor
            return
        }
        if (text.count == 0) {
            sender.layer.borderColor = UIColor.white.cgColor
            return
        }
        let userInput = WUtils.localeStringToDecimal(text)
        if (text.count > 1 && userInput == NSDecimalNumber.zero) {
            sender.layer.borderColor = UIColor.init(hexString: "f31963").cgColor
            return
        }
        if (userInput.multiplying(byPowerOf10: cDpDecimal).compare(cMaxWithdrawableAmount).rawValue > 0) {
            sender.layer.borderColor = UIColor.init(hexString: "f31963").cgColor
            return
        }
        sender.layer.borderColor = UIColor.white.cgColor
    }
    
    @IBAction func onClickCAmountClear(_ sender: UIButton) {
        cAmountInput.text = ""
        onUpdateNextBtn()
    }
    
    @IBAction func onClickCMin(_ sender: UIButton) {
        var exist = NSDecimalNumber.zero
        if (cAmountInput.text!.count > 0) {
            exist = NSDecimalNumber(string: cAmountInput.text!, locale: Locale.current)
        }
        let added = exist.adding(NSDecimalNumber(string: "1"))
        cAmountInput.text = WUtils.decimalNumberToLocaleString(added, cDpDecimal)
        self.AmountChanged(cAmountInput)
    }
    
    @IBAction func onClickC1_4(_ sender: UIButton) {
        let calValue = cMaxWithdrawableAmount.multiplying(by: NSDecimalNumber.init(string: "0.25")).multiplying(byPowerOf10: -cDpDecimal, withBehavior: WUtils.getDivideHandler(cDpDecimal))
        cAmountInput.text = WUtils.decimalNumberToLocaleString(calValue, cDpDecimal)
        self.AmountChanged(cAmountInput)
    }
    
    @IBAction func onClickCHalf(_ sender: UIButton) {
        let calValue = cMaxWithdrawableAmount.dividing(by: NSDecimalNumber(2)).multiplying(byPowerOf10: -cDpDecimal, withBehavior: WUtils.getDivideHandler(cDpDecimal))
        cAmountInput.text = WUtils.decimalNumberToLocaleString(calValue, cDpDecimal)
        self.AmountChanged(cAmountInput)
    }
    
    @IBAction func onClickC3_4(_ sender: UIButton) {
        let calValue = cMaxWithdrawableAmount.multiplying(by: NSDecimalNumber.init(string: "0.75")).multiplying(byPowerOf10: -cDpDecimal, withBehavior: WUtils.getDivideHandler(cDpDecimal))
        cAmountInput.text = WUtils.decimalNumberToLocaleString(calValue, cDpDecimal)
        self.AmountChanged(cAmountInput)
    }
    
    @IBAction func onClickCMax(_ sender: UIButton) {
        let maxValue = cMaxWithdrawableAmount.multiplying(byPowerOf10: -cDpDecimal, withBehavior: WUtils.getDivideHandler(cDpDecimal))
        cAmountInput.text = WUtils.decimalNumberToLocaleString(maxValue, cDpDecimal)
        self.AmountChanged(cAmountInput)
    }
    
    @IBAction func onClickCancel(_ sender: UIButton) {
        self.btnCancel.isUserInteractionEnabled = false
        self.btnNext.isUserInteractionEnabled = false
        pageHolderVC.onBeforePage()
    }
    
    @IBAction func onClickNext(_ sender: UIButton) {
        if (isValiadCAmount()) {
            view.endEditing(true)
            let popupVC = RiskCheckPopupViewController(nibName: "RiskCheckPopupViewController", bundle: nil)
            popupVC.type = popupVC.RISK_POPUP_CHANGE
            popupVC.cDenom = self.mCDenom
            popupVC.DNcurrentPrice = self.currentPrice
            popupVC.DNbeforeLiquidationPrice = self.beforeLiquidationPrice
            popupVC.DNbeforeRiskRate = self.beforeRiskRate
            popupVC.DNafterLiquidationPrice = self.afterLiquidationPrice
            popupVC.DNafterRiskRate = self.afterRiskRate
            
            let cardPopup = SBCardPopupViewController(contentViewController: popupVC)
            cardPopup.resultDelegate = self
            cardPopup.show(onViewController: self)

        } else {
            self.onShowToast(NSLocalizedString("error_amount", comment: ""))
        }
    }
    
    func SBCardPopupResponse(type:Int, result: Int) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300), execute: {
            if(result == 10) {
                let cCoin = Coin.init(self.mCDenom, self.toCAmount.stringValue)
                self.pageHolderVC.mCollateral = cCoin

                self.pageHolderVC.currentPrice = self.currentPrice
                self.pageHolderVC.beforeLiquidationPrice = self.beforeLiquidationPrice
                self.pageHolderVC.afterLiquidationPrice = self.afterLiquidationPrice
                self.pageHolderVC.beforeRiskRate = self.beforeRiskRate
                self.pageHolderVC.afterRiskRate = self.afterRiskRate
                self.pageHolderVC.pDenom = self.mPDenom
                self.pageHolderVC.totalDepositAmount = self.sumCAmount
                self.pageHolderVC.mCollateralParam = self.mCollateralParam

                self.btnCancel.isUserInteractionEnabled = false
                self.btnNext.isUserInteractionEnabled = false
                self.pageHolderVC.onNextPage()
            }
        })
    }
    
    func isValiadCAmount() -> Bool {
        let text = cAmountInput.text?.trimmingCharacters(in: .whitespaces)
        if (text == nil || text!.count == 0) { return false }
        let userInput = WUtils.localeStringToDecimal(text!)
        if (userInput == NSDecimalNumber.zero) { return false }
        if (userInput.multiplying(byPowerOf10: cDpDecimal).compare(cMaxWithdrawableAmount).rawValue > 0 ||
            userInput.multiplying(byPowerOf10: cDpDecimal).compare(NSDecimalNumber.zero).rawValue < 0) {
            return false
        }
        toCAmount = userInput.multiplying(byPowerOf10: cDpDecimal)
        sumCAmount = myCdp!.getTotalCollateralAmount().subtracting(toCAmount)
        let collateralAmount = sumCAmount.multiplying(byPowerOf10: -cDpDecimal)
        let rawDebtAmount = myCdp!.cdp!.getEstimatedTotalDebt(mCollateralParam!).multiplying(by: mCollateralParam!.getLiquidationRatio()).multiplying(byPowerOf10: -pDpDecimal)

        afterLiquidationPrice = rawDebtAmount.dividing(by: collateralAmount, withBehavior: WUtils.getDivideHandler(pDpDecimal))
        afterRiskRate = NSDecimalNumber.init(string: "100").subtracting(currentPrice.subtracting(afterLiquidationPrice).multiplying(byPowerOf10: 2).dividing(by: currentPrice, withBehavior: WUtils.handler2Down))
        
//        print("currentPrice ", currentPrice)
//        print("afterLiquidationPrice ", afterLiquidationPrice)
//        print("afterRiskRate ", afterRiskRate)
        return true
    }

    func onUpdateNextBtn() {
        if (!isValiadCAmount()) {
            btnNext.backgroundColor = UIColor.clear
            btnNext.setTitle(NSLocalizedString("tx_next", comment: ""), for: .normal)
            btnNext.setTitleColor(COLOR_PHOTON, for: .normal)
            btnNext.layer.borderWidth = 1.0
            afterSafeRate.isHidden = true
            afterSafeTxt.isHidden = true
        } else {
            btnNext.setTitleColor(UIColor.black, for: .normal)
            btnNext.layer.borderWidth = 0.0
            if (afterRiskRate.doubleValue <= 50) {
                btnNext.backgroundColor = COLOR_CDP_SAFE
                btnNext.setTitle("SAFE", for: .normal)
                
            } else if (afterRiskRate.doubleValue < 80) {
                btnNext.backgroundColor = COLOR_CDP_STABLE
                btnNext.setTitle("STABLE", for: .normal)
                
            } else {
                btnNext.backgroundColor = COLOR_CDP_DANGER
                btnNext.setTitle("DANGER", for: .normal)
            }
            WUtils.showRiskRate2(afterRiskRate, afterSafeRate, afterSafeTxt)
            afterSafeRate.isHidden = false
            afterSafeTxt.isHidden = false
        }
    }
    
    
    var mFetchCnt = 0
    func onFetchCdpData() {
        self.mFetchCnt = 3
        onFetchKavaPrice(self.mMarketID)
        onFetchOwenCdp(account!.account_address)
        onFetchCdpDeposit(account!, self.mCollateralParamType!)
    }
    
    func onFetchFinished() {
        self.mFetchCnt = self.mFetchCnt - 1
        if (mFetchCnt <= 0) {
            self.mCDenom = mCollateralParam!.getcDenom()!
            self.mPDenom = mCollateralParam!.getpDenom()!
            self.cDpDecimal = WUtils.getKavaCoinDecimal(mCDenom)
            self.pDpDecimal = WUtils.getKavaCoinDecimal(mPDenom)
            self.currentPrice = NSDecimalNumber.init(string: mPrice?.result.price)
            
            beforeLiquidationPrice = myCdp!.getLiquidationPrice(mCDenom, mPDenom, mCollateralParam!)
            beforeRiskRate = NSDecimalNumber.init(string: "100").subtracting(currentPrice.subtracting(beforeLiquidationPrice).multiplying(byPowerOf10: 2).dividing(by: currentPrice, withBehavior: WUtils.handler2Down))
            WUtils.showRiskRate2(beforeRiskRate, beforeSafeRate, beforeSafeTxt)
            
            cMaxWithdrawableAmount = myCdp!.getWithdrawableAmount(mCDenom, mPDenom, mCollateralParam!, currentPrice, mSelfDepositAmount)
            cAvailabeMaxLabel.attributedText = WUtils.displayAmount2(cMaxWithdrawableAmount.stringValue, cAvailabeMaxLabel.font!, cDpDecimal, cDpDecimal)
            
//            print("currentPrice ", currentPrice)
//            print("beforeLiquidationPrice ", beforeLiquidationPrice)
//            print("beforeRiskRate ", beforeRiskRate)
            
            cDenomLabel.text = mCDenom.uppercased()
            cAvailableDenom.text = mCDenom.uppercased()
            let cUrl = KAVA_COIN_IMG_URL + mCDenom + ".png"
            self.cDenomImg.af_setImage(withURL: URL(string: cUrl)!)
            self.loadingImg.onStopAnimation()
            self.loadingImg.isHidden = true
            
        }
    }
    
    func onFetchKavaPrice(_ market:String) {
        let request = Alamofire.request(BaseNetWork.priceFeedUrl(chainType, market), method: .get, parameters: [:], encoding: URLEncoding.default, headers: [:])
        request.responseJSON { (response) in
            switch response.result {
                case .success(let res):
                    guard let responseData = res as? NSDictionary,
                        let _ = responseData.object(forKey: "height") as? String else {
                            self.onFetchFinished()
                            return
                    }
                    self.mPrice = KavaPriceFeedPrice.init(responseData)
//                    print("mPrice ", self.mPrice)

                case .failure(let error):
                    if (SHOW_LOG) { print("onFetchKavaPrice ", market , " ", error) }
                }
            self.onFetchFinished()
        }
    }
    
    func onFetchOwenCdp(_ address: String) {
        let request = Alamofire.request(BaseNetWork.owenCdpUrl(chainType), method: .get, parameters: ["owner":address], encoding: URLEncoding.default, headers: [:]);
        request.responseJSON { (response) in
            switch response.result {
                case .success(let res):
                    guard let responseData = res as? NSDictionary, let _ = responseData.object(forKey: "height") as? String else {
                        self.onFetchFinished()
                        return
                    }
                    let myCdps = KavaMyCdps.init(responseData)
                    self.myCdp = myCdps.result?.filter { $0.cdp?.type == self.mCollateralParamType}.first
//                    print("myCdp ", self.myCdp)
                    
                case .failure(let error):
                    if (SHOW_LOG) { print("onFetchOwenCdp ", error) }
                }
            self.onFetchFinished()
        }
    }
    
    func onFetchCdpDeposit(_ account:Account, _ collateralType: String) {
        let request = Alamofire.request(BaseNetWork.depositCdpUrl(chainType, account.account_address, collateralType), method: .get, parameters: [:], encoding: URLEncoding.default, headers: [:])
        request.responseJSON { (response) in
            switch response.result {
            case .success(let res):
                guard let responseData = res as? NSDictionary, let _ = responseData.object(forKey: "height") as? String else {
                    self.onFetchFinished()
                    return
                }
                let cdpDeposits = KavaCdpDeposits.init(responseData)
                if let selfDeposit = cdpDeposits.result?.filter({ $0.depositor == self.account?.account_address}).first {
                    self.mSelfDepositAmount = NSDecimalNumber.init(string: selfDeposit.amount?.amount)
                }
//                print("mSelfDepositAmount ", self.mSelfDepositAmount)
                
            case .failure(let error):
                if (SHOW_LOG) { print("onFetchCdpDeposit ", error) }
            }
            self.onFetchFinished()
        }
    }
}
