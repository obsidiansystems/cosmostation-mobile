package wannabit.io.cosmostaion.task.FetchTask;

import java.util.ArrayList;

import retrofit2.Response;
import wannabit.io.cosmostaion.base.BaseApplication;
import wannabit.io.cosmostaion.base.BaseChain;
import wannabit.io.cosmostaion.base.BaseConstant;
import wannabit.io.cosmostaion.network.ApiClient;
import wannabit.io.cosmostaion.network.res.ResApiNewTxListCustom;
import wannabit.io.cosmostaion.network.res.ResApiTxList;
import wannabit.io.cosmostaion.network.res.ResApiTxListCustom;
import wannabit.io.cosmostaion.task.CommonTask;
import wannabit.io.cosmostaion.task.TaskListener;
import wannabit.io.cosmostaion.task.TaskResult;
import wannabit.io.cosmostaion.utils.WLog;

import static wannabit.io.cosmostaion.base.BaseChain.ALTHEA_TEST;
import static wannabit.io.cosmostaion.base.BaseChain.CRYPTO_MAIN;
import static wannabit.io.cosmostaion.base.BaseChain.MEDI_TEST;
import static wannabit.io.cosmostaion.base.BaseChain.OSMOSIS_MAIN;
import static wannabit.io.cosmostaion.base.BaseChain.PERSIS_MAIN;
import static wannabit.io.cosmostaion.base.BaseChain.RIZON_TEST;

public class ApiStakeTxsHistoryTask extends CommonTask {

    private String mAddress;
    private String mValOpAddress;
    private BaseChain mChain;

    public ApiStakeTxsHistoryTask(BaseApplication app, TaskListener listener, String address, String vAddress, BaseChain chain) {
        super(app, listener);
        this.mResult.taskType   = BaseConstant.TASK_FETCH_API_STAKE_HISTORY;
        this.mAddress = address;
        this.mValOpAddress = vAddress;
        this.mChain = chain;
    }


    @Override
    protected TaskResult doInBackground(String... strings) {
        try {
            if (mChain.equals(BaseChain.KAVA_MAIN)) {
                Response<ArrayList<ResApiNewTxListCustom>> response = ApiClient.getKavaApi(mApp).getNewStakeTxsCustom(mAddress, mValOpAddress, "50").execute();
                if (response.isSuccessful() && response.body() != null) {
                    mResult.resultData = response.body();
                    mResult.isSuccess = true;
                } else {
                    WLog.w("ApiStakeTxsHistoryTask : NOk");
                }
            } else if (mChain.equals(BaseChain.KAVA_TEST)) {
                Response<ArrayList<ResApiNewTxListCustom>> response = ApiClient.getKavaTestApi(mApp).getNewStakeTxsCustom(mAddress, mValOpAddress, "50").execute();
                if (response.isSuccessful() && response.body() != null) {
                    mResult.resultData = response.body();
                    mResult.isSuccess = true;
                } else {
                    WLog.w("ApiStakeTxsHistoryTask : NOk");
                }

            } else if (mChain.equals(BaseChain.BAND_MAIN)) {
                Response<ArrayList<ResApiTxList.Data>> response = ApiClient.getBandApi(mApp).getStakeTxs(mAddress, mValOpAddress).execute();
                if (response.isSuccessful() && response.body() != null) {
                    mResult.resultData = response.body();
                    mResult.isSuccess = true;
                } else {
                    WLog.w("ApiStakeTxsHistoryTask : NOk");
                }

            } else if (mChain.equals(BaseChain.CERTIK_MAIN)) {
                Response<ArrayList<ResApiTxList.Data>> response = ApiClient.getCertikApi(mApp).getStakeTxs(mAddress, mValOpAddress).execute();
                if (response.isSuccessful() && response.body() != null) {
                    mResult.resultData = response.body();
                    mResult.isSuccess = true;
                } else {
                    WLog.w("ApiStakeTxsHistoryTask : NOk");
                }

            } else if (mChain.equals(BaseChain.CERTIK_TEST)) {
                Response<ArrayList<ResApiTxList.Data>> response = ApiClient.getCertikTestApi(mApp).getStakeTxs(mAddress, mValOpAddress).execute();
                if (response.isSuccessful() && response.body() != null) {
                    mResult.resultData = response.body();
                    mResult.isSuccess = true;
                } else {
                    WLog.w("ApiStakeTxsHistoryTask : NOk");
                }

            } else if (mChain.equals(BaseChain.FETCHAI_MAIN)) {
                Response<ArrayList<ResApiNewTxListCustom>> response = ApiClient.getFetchApi(mApp).getNewStakeTxsCustom(mAddress, mValOpAddress, "50").execute();
                if (response.isSuccessful() && response.body() != null) {
                    mResult.resultData = response.body();
                    mResult.isSuccess = true;
                } else {
                    WLog.w("ApiStakeTxsHistoryTask : NOk");
                }

            } else if (mChain.equals(BaseChain.SIF_MAIN)) {
                Response<ArrayList<ResApiNewTxListCustom>> response = ApiClient.getSifApi(mApp).getNewStakeTxsCustom(mAddress, mValOpAddress, "50").execute();
                if (response.isSuccessful() && response.body() != null) {
                    mResult.resultData = response.body();
                    mResult.isSuccess = true;
                } else {
                    WLog.w("ApiStakeTxsHistoryTask : NOk");
                }

            } else if (mChain.equals(BaseChain.KI_MAIN)) {
                Response<ArrayList<ResApiTxList.Data>> response = ApiClient.getKiApi(mApp).getStakeTxs(mAddress, mValOpAddress).execute();
                if (response.isSuccessful() && response.body() != null) {
                    mResult.resultData = response.body();
                    mResult.isSuccess = true;
                } else {
                    WLog.w("ApiStakeTxsHistoryTask : NOk");
                }

            }

            if (mChain.equals(BaseChain.COSMOS_MAIN)) {
                Response<ArrayList<ResApiNewTxListCustom>> response = ApiClient.getCosmosApi(mApp).getNewStakeTxsCustom(mAddress, mValOpAddress, "50").execute();
                if (response.isSuccessful() && response.body() != null) {
                    mResult.resultData = response.body();
                    mResult.isSuccess = true;
                } else {
                    WLog.w("ApiStakeTxsHistoryTask : NOk");
                }

            } else if (mChain.equals(BaseChain.IRIS_MAIN)) {
                Response<ArrayList<ResApiNewTxListCustom>> response = ApiClient.getIrisApi(mApp).getNewStakeTxsCustom(mAddress, mValOpAddress, "50").execute();
                if (response.isSuccessful() && response.body() != null) {
                    mResult.resultData = response.body();
                    mResult.isSuccess = true;
                } else {
                    WLog.w("ApiStakeTxsHistoryTask : NOk");
                }

            } else if (mChain.equals(BaseChain.AKASH_MAIN)) {
                Response<ArrayList<ResApiNewTxListCustom>> response = ApiClient.getAkashApi(mApp).getNewStakeTxsCustom(mAddress, mValOpAddress,  "50").execute();
                if (response.isSuccessful() && response.body() != null) {
                    mResult.resultData = response.body();
                    mResult.isSuccess = true;
                } else {
                    WLog.w("ApiStakeTxsHistoryTask : NOk");
                }

            } else if (mChain.equals(BaseChain.SENTINEL_MAIN)) {
                Response<ArrayList<ResApiNewTxListCustom>> response = ApiClient.getSentinelApi(mApp).getNewStakeTxsCustom(mAddress, mValOpAddress,  "50").execute();
                if (response.isSuccessful() && response.body() != null) {
                    mResult.resultData = response.body();
                    mResult.isSuccess = true;
                } else {
                    WLog.w("ApiStakeTxsHistoryTask : NOk");
                }

            } else if (mChain.equals(PERSIS_MAIN)) {
                Response<ArrayList<ResApiNewTxListCustom>> response = ApiClient.getPersisApi(mApp).getNewStakeTxsCustom(mAddress, mValOpAddress,  "50").execute();
                if (response.isSuccessful() && response.body() != null) {
                    mResult.resultData = response.body();
                    mResult.isSuccess = true;
                } else {
                    WLog.w("ApiStakeTxsHistoryTask : NOk");
                }

            } else if (mChain.equals(CRYPTO_MAIN)) {
                Response<ArrayList<ResApiTxListCustom>> response = ApiClient.getCryptoApi(mApp).getStakeTxsCustom(mAddress, mValOpAddress,  "50").execute();
                if (response.isSuccessful() && response.body() != null) {
                    mResult.resultData = response.body();
                    mResult.isSuccess = true;
                } else {
                    WLog.w("ApiStakeTxsHistoryTask : NOk");
                }

            } else if (mChain.equals(OSMOSIS_MAIN)) {
                Response<ArrayList<ResApiNewTxListCustom>> response = ApiClient.getOsmosisApi(mApp).getNewStakeTxsCustom(mAddress, mValOpAddress,  "50").execute();
                if (response.isSuccessful() && response.body() != null) {
                    mResult.resultData = response.body();
                    mResult.isSuccess = true;
                } else {
                    WLog.w("ApiStakeTxsHistoryTask : NOk");
                }

            } else if (mChain.equals(BaseChain.IOV_MAIN)) {
                Response<ArrayList<ResApiNewTxListCustom>> response = ApiClient.getIovApi(mApp).getNewStakeTxsCustom(mAddress, mValOpAddress,  "50").execute();
                if (response.isSuccessful() && response.body() != null) {
                    mResult.resultData = response.body();
                    mResult.isSuccess = true;
                }

            } else if (mChain.equals(BaseChain.MEDI_MAIN) || mChain.equals(MEDI_TEST)) {
                Response<ArrayList<ResApiNewTxListCustom>> response = ApiClient.getMediblocApi(mApp).getNewStakeTxsCustom(mAddress, mValOpAddress,  "50").execute();
                if (response.isSuccessful() && response.body() != null) {
                    mResult.resultData = response.body();
                    mResult.isSuccess = true;
                }

//            } else if (mChain.equals(BaseChain.BAND_MAIN)) {
//                Response<ArrayList<ResApiNewTxListCustom>> response = ApiClient.getBandApi(mApp).getNewStakeTxsCustom(mAddress, mValOpAddress,  "50").execute();
//                if (response.isSuccessful() && response.body() != null) {
//                    mResult.resultData = response.body();
//                    mResult.isSuccess = true;
//                }

            }

            else if (mChain.equals(BaseChain.COSMOS_TEST)) {
                Response<ArrayList<ResApiNewTxListCustom>> response = ApiClient.getCosmosTestApi(mApp).getNewStakeTxsCustom(mAddress, mValOpAddress, "50").execute();
                if (response.isSuccessful() && response.body() != null) {
                    mResult.resultData = response.body();
                    mResult.isSuccess = true;
                } else {
                    WLog.w("ApiStakeTxsHistoryTask : NOk");
                }
            } else if (mChain.equals(BaseChain.IRIS_TEST)) {
                Response<ArrayList<ResApiNewTxListCustom>> response = ApiClient.getIrisTestApi(mApp).getNewStakeTxsCustom(mAddress, mValOpAddress, "50").execute();
                if (response.isSuccessful() && response.body() != null) {
                    mResult.resultData = response.body();
                    mResult.isSuccess = true;
                } else {
                    WLog.w("ApiStakeTxsHistoryTask : NOk");
                }

            } else if (mChain.equals(RIZON_TEST)) {
                Response<ArrayList<ResApiNewTxListCustom>> response = ApiClient.getRizonTestApi(mApp).getNewStakeTxsCustom(mAddress, mValOpAddress, "50").execute();
                if (response.isSuccessful() && response.body() != null) {
                    mResult.resultData = response.body();
                    mResult.isSuccess = true;
                } else {
                    WLog.w("ApiStakeTxsHistoryTask : NOk");
                }
            } else if (mChain.equals(ALTHEA_TEST)) {
                Response<ArrayList<ResApiNewTxListCustom>> response = ApiClient.getAltheaTestApi(mApp).getNewStakeTxsCustom(mAddress, mValOpAddress, "50").execute();
                if (response.isSuccessful() && response.body() != null) {
                    mResult.resultData = response.body();
                    mResult.isSuccess = true;
                } else {
                    WLog.w("ApiStakeTxsHistoryTask : NOk");
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
            WLog.w("ApiStakeTxsHistoryTask Error " + e.getMessage());
        }
        return mResult;
    }

}
