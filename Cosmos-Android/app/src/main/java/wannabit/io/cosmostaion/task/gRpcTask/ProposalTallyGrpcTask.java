package wannabit.io.cosmostaion.task.gRpcTask;

import cosmos.gov.v1beta1.QueryGrpc;
import cosmos.gov.v1beta1.QueryOuterClass;
import wannabit.io.cosmostaion.base.BaseApplication;
import wannabit.io.cosmostaion.base.BaseChain;
import wannabit.io.cosmostaion.network.ChannelBuilder;
import wannabit.io.cosmostaion.task.CommonTask;
import wannabit.io.cosmostaion.task.TaskListener;
import wannabit.io.cosmostaion.task.TaskResult;
import wannabit.io.cosmostaion.utils.WLog;

import static wannabit.io.cosmostaion.base.BaseConstant.TASK_GRPC_FETCH_PROPOSAL_TALLY;

public class ProposalTallyGrpcTask extends CommonTask {
    private BaseChain mChain;
    private String mProposalId;
    private QueryGrpc.QueryBlockingStub mStub;

    public ProposalTallyGrpcTask(BaseApplication app, TaskListener listener, BaseChain chain, String proposalId) {
        super(app, listener);
        this.mChain = chain;
        this.mProposalId = proposalId;
        this.mResult.taskType = TASK_GRPC_FETCH_PROPOSAL_TALLY;
        this.mStub = QueryGrpc.newBlockingStub(ChannelBuilder.getChain(mChain));
    }

    @Override
    protected TaskResult doInBackground(String... strings) {
        try {
            QueryOuterClass.QueryTallyResultRequest request = QueryOuterClass.QueryTallyResultRequest.newBuilder().setProposalId(Long.parseLong(mProposalId)).build();
            QueryOuterClass.QueryTallyResultResponse response = mStub.tallyResult(request);
            this.mResult.resultData = response.getTally();
//            WLog.w("ProposalsGrpcTask " + response.getProposalsList());

        } catch (Exception e) { WLog.e( "ProposalsGrpcTask "+ e.getMessage()); }
        return mResult;
    }

}