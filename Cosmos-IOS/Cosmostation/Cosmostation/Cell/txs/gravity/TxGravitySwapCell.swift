//
//  TxGravitySwapCell.swift
//  Cosmostation
//
//  Created by 정용주 on 2021/07/13.
//  Copyright © 2021 wannabit. All rights reserved.
//

import UIKit

class TxGravitySwapCell: TxCell {
    
    @IBOutlet weak var txIcon: UIImageView!
    @IBOutlet weak var txRequesterLabel: UILabel!
    @IBOutlet weak var txPoolIDLabel: UILabel!
    @IBOutlet weak var txSwapTypeIDLabel: UILabel!
    @IBOutlet weak var txOrderPriceLabel: UILabel!
    @IBOutlet weak var txSwapFeeAmountLabel: UILabel!
    @IBOutlet weak var txSwapFeeDenomLabel: UILabel!
    @IBOutlet weak var txOfferInAmountLabel: UILabel!
    @IBOutlet weak var txOfferInDenomLabel: UILabel!
    @IBOutlet weak var txOfferOutAmountLabel: UILabel!
    @IBOutlet weak var txOfferOutDenomLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        
        txSwapFeeAmountLabel.font = UIFontMetrics(forTextStyle: .caption1).scaledFont(for: Font_12_caption1)
        txOfferInAmountLabel.font = UIFontMetrics(forTextStyle: .caption1).scaledFont(for: Font_12_caption1)
        txOfferOutAmountLabel.font = UIFontMetrics(forTextStyle: .caption1).scaledFont(for: Font_12_caption1)
    }
    
    override func onBindMsg(_ chain: ChainType, _ response: Cosmos_Tx_V1beta1_GetTxResponse, _ position: Int) {
        txIcon.image = txIcon.image?.withRenderingMode(.alwaysTemplate)
        txIcon.tintColor = WUtils.getChainColor(chain)
        
        let msg = try! Tendermint_Liquidity_V1beta1_MsgSwapWithinBatch.init(serializedData: response.tx.body.messages[position].value)
        txRequesterLabel.text = msg.swapRequesterAddress
        txRequesterLabel.adjustsFontSizeToFitWidth = true
        
        txPoolIDLabel.text = String(msg.poolID)
        txSwapTypeIDLabel.text = String(msg.swapTypeID)
        txOrderPriceLabel.text = NSDecimalNumber.init(string: msg.orderPrice).multiplying(byPowerOf10: -18).stringValue
        
        txSwapFeeAmountLabel.text = ""
        txSwapFeeDenomLabel.text = ""
        txOfferInAmountLabel.text = ""
        txOfferInDenomLabel.text = ""
        txOfferOutAmountLabel.text = ""
        txOfferOutDenomLabel.text = ""
        
    }
    
}
