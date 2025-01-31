package wannabit.io.cosmostaion.base;

import java.math.BigDecimal;
import java.util.ArrayList;

import osmosis.gamm.v1beta1.PoolOuterClass;
import osmosis.gamm.v1beta1.Tx;
import starnamed.x.starname.v1beta1.Types;
import wannabit.io.cosmostaion.model.hdac.HdacUtxo;
import wannabit.io.cosmostaion.model.type.Coin;
import wannabit.io.cosmostaion.model.type.Fee;
import wannabit.io.cosmostaion.model.type.Validator;

public class BaseBroadCastActivity extends BaseActivity {

    public int                          mTxType = -1;
    public Fee                          mTxFee;
    public String                       mTxMemo;
    public String                       mDenom;                             //Transfer
    public String                       mToAddress;                         //Transfer
    public ArrayList<Coin>              mAmounts;                           //Transfer
    public Coin                         mAmount;                            //Delegate, Undelegate, Redelegate, ReInvest
    public String                       mValAddress;                        //Delegate, Undelegate, ReInvest
    public String                       mToValAddress;                      //Redelegate
    public ArrayList<Coin>              mRewards = new ArrayList<>();       //Reward
    public ArrayList<String>            mValAddresses = new ArrayList<>();  //ClaimReward
    public String                       mNewRewardAddress;                  //SetRewardAddress
    public String                       mProposalId;                        //Vote
    public String                       mOpinion;                           //Vote

    public String                       mStarNameDomain;                            //starname domain
    public String                       mStarNameDomainType;                        //starname domain type
    public String                       mStarNameAccount;                           //starname
    public ArrayList<Types.Resource>    mStarNameResources = new ArrayList();       //starname


    public Tx.SwapAmountInRoute         mOsmosisSwapAmountInRoute;                          // osmosis
    public long                         mOsmosisPoolId;
    public PoolOuterClass.Pool          mOsmosisPool;
    public Coin                         mOsmosisPoolCoin0;
    public Coin                         mOsmosisPoolCoin1;
    public Coin                         mOsmosisLpToken;
    public Coin                         mOsmosisSwapInCoin;
    public Coin                         mOsmosisSwapOutCoin;

    public ArrayList<HdacUtxo>          mHdacUtxo;                                  //rizon swap;
    public BigDecimal                   mHdacBalance;                               //rizon swap amount
    public ArrayList<String>            mHdacWords;                                 //rizon swap Hdac Mnemonic words

    public ArrayList<Validator> mValidators = new ArrayList<>();    //ClaimReward old


    public void onNextStep() { }

    public void onBeforeStep() { }

    public void onBroadcastTx() {

    }
}
