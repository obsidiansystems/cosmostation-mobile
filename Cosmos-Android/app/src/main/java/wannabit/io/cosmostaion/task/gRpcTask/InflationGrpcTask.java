package wannabit.io.cosmostaion.task.gRpcTask;


import java.math.BigDecimal;
import java.util.concurrent.TimeUnit;

import cosmos.mint.v1beta1.QueryGrpc;
import cosmos.mint.v1beta1.QueryOuterClass;
import wannabit.io.cosmostaion.base.BaseApplication;
import wannabit.io.cosmostaion.base.BaseChain;
import wannabit.io.cosmostaion.network.ChannelBuilder;
import wannabit.io.cosmostaion.task.CommonTask;
import wannabit.io.cosmostaion.task.TaskListener;
import wannabit.io.cosmostaion.task.TaskResult;
import wannabit.io.cosmostaion.utils.WLog;

import static wannabit.io.cosmostaion.base.BaseConstant.TASK_GRPC_FETCH_INFLATION;
import static wannabit.io.cosmostaion.network.ChannelBuilder.TIME_OUT;

public class InflationGrpcTask extends CommonTask {
    private BaseChain mChain;
    private QueryGrpc.QueryBlockingStub mStub;

    public InflationGrpcTask(BaseApplication app, TaskListener listener, BaseChain chain) {
        super(app, listener);
        this.mChain = chain;
        this.mResult.taskType = TASK_GRPC_FETCH_INFLATION;
        this.mResult.resultData = BigDecimal.ZERO;
        this.mStub = QueryGrpc.newBlockingStub(ChannelBuilder.getChain(mChain)).withDeadlineAfter(TIME_OUT, TimeUnit.SECONDS);;
    }

    @Override
    protected TaskResult doInBackground(String... strings) {
        try {
            QueryOuterClass.QueryInflationRequest request = QueryOuterClass.QueryInflationRequest.newBuilder().build();
            QueryOuterClass.QueryInflationResponse response = mStub.inflation(request);
//            WLog.w("Inflation " + response.getInflation().toString("UTF-8"));
            BigDecimal inflation = new BigDecimal(response.getInflation().toString("UTF-8")).movePointLeft(18);
            this.mResult.isSuccess = true;
            this.mResult.resultData = inflation;

        } catch (Exception e) { WLog.e( "InflationGrpcTask "+ e.getMessage()); }
        return mResult;
    }

}
