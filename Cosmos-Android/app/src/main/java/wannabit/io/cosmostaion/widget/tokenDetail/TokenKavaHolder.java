package wannabit.io.cosmostaion.widget.tokenDetail;

import android.content.Context;
import android.view.View;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;

import androidx.annotation.NonNull;

import java.math.BigDecimal;

import wannabit.io.cosmostaion.R;
import wannabit.io.cosmostaion.base.BaseChain;
import wannabit.io.cosmostaion.base.BaseData;
import wannabit.io.cosmostaion.utils.WDp;
import wannabit.io.cosmostaion.widget.BaseHolder;

import static wannabit.io.cosmostaion.base.BaseConstant.TOKEN_KAVA;

public class TokenKavaHolder extends BaseHolder {


    private LinearLayout    mKavaTransfer;
    private RelativeLayout  mBtnSendKava, mBtnReceiveKava;
    private RelativeLayout  mKavaVestingLayer, mKavaDepositLayer, mKavaIncentiveLayer;
    private TextView        mTvKavaTotal, mTvKavaValue, mTvKavaAvailable, mTvKavaVesting,
                            mTvKavaDelegated, mTvKavaUnBonding, mTvKavaRewards, mTvKavaDeposit, mTvKavaIncentive;

    public TokenKavaHolder(@NonNull View itemView) {
        super(itemView);
        mTvKavaTotal            = itemView.findViewById(R.id.dash_kava_amount);
        mTvKavaValue            = itemView.findViewById(R.id.dash_kava_value);
        mTvKavaAvailable        = itemView.findViewById(R.id.dash_kava_undelegate);
        mTvKavaDelegated        = itemView.findViewById(R.id.dash_kava_delegate);
        mTvKavaUnBonding        = itemView.findViewById(R.id.dash_kava_unbonding);
        mTvKavaRewards          = itemView.findViewById(R.id.dash_kava_reward);
        mTvKavaVesting          = itemView.findViewById(R.id.dash_kava_vesting);
        mTvKavaDeposit          = itemView.findViewById(R.id.dash_kava_harvest_deposited);
        mTvKavaIncentive        = itemView.findViewById(R.id.dash_kava_unclaimed_incentive);

        mKavaVestingLayer       = itemView.findViewById(R.id.kava_harvest_vesting_layer);
        mKavaDepositLayer       = itemView.findViewById(R.id.kava_harvest_deposit_layer);
        mKavaIncentiveLayer     = itemView.findViewById(R.id.kava_harvest_incentive_layer);


        mKavaTransfer           = itemView.findViewById(R.id.layer_kava_transfer);
        mBtnSendKava            = itemView.findViewById(R.id.btn_kava_send);
        mBtnReceiveKava         = itemView.findViewById(R.id.btn_kava_receive);
        mKavaTransfer.setVisibility(View.GONE);
    }

    @Override
    public void onBindTokenHolder(Context c,  BaseChain chain, BaseData baseData, String denom) {
        final BigDecimal availableAmount = baseData.availableAmount(TOKEN_KAVA);
        final BigDecimal vestingAmount = baseData.lockedAmount(TOKEN_KAVA);
        final BigDecimal delegateAmount = baseData.delegatedSumAmount();
        final BigDecimal unbondingAmount = baseData.unbondingSumAmount();
        final BigDecimal rewardAmount = baseData.rewardAmount(TOKEN_KAVA);
        final BigDecimal totalAmount = baseData.getAllMainAssetOld(TOKEN_KAVA);

        mTvKavaTotal.setText(WDp.getDpAmount2(c, totalAmount, 6, 6));
        mTvKavaAvailable.setText(WDp.getDpAmount2(c, availableAmount, 6, 6));
        mTvKavaDelegated.setText(WDp.getDpAmount2(c, delegateAmount, 6, 6));
        mTvKavaUnBonding.setText(WDp.getDpAmount2(c, unbondingAmount, 6, 6));
        mTvKavaRewards.setText(WDp.getDpAmount2(c, rewardAmount, 6, 6));
        mTvKavaVesting.setText(WDp.getDpAmount2(c, vestingAmount, 6, 6));
        mTvKavaValue.setText(WDp.dpUserCurrencyValue(baseData, denom, totalAmount, 6));

        if (!vestingAmount.equals(BigDecimal.ZERO)) {
            mKavaVestingLayer.setVisibility(View.VISIBLE);
        }

    }
}
