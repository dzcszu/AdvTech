function [fsAcc,fsSen,fsSpec,fsPrec,maxFscore,maxAuc,maxAcc,minArmse,maxBcc,minBrmse,Rs,Ra,Rb]=...
    my_combineSVM_SVR_maxFS(trainData,trainFlag,trainScoresA,trainScoresB,testData,testFlag,testScoresA,testScoresB,parc,parg)

lparc=length(parc);
lparg=length(parg);

% 预定义
svrDataA{lparc,lparg}=[];
Acc(lparc,lparg)=0;
Armse(lparc,lparg)=0;
Adec{lparc,lparg}=[];
Atest{lparc,lparg}=[];

svrDataB{lparc,lparg}=[];
Bcc(lparc,lparg)=0;
Brmse(lparc,lparg)=0;
Bdec{lparc,lparg}=[];
Btest{lparc,lparg}=[];


svmData{lparc,lparg}=[];
SVMacc(lparc,lparg)=0;
SVMsen(lparc,lparg)=0;
SVMspec(lparc,lparg)=0;
SVMprec(lparc,lparg)=0;
SVMauc(lparc,lparg)=0;
SVMfscore(lparc,lparg)=0;
SVMldec{lparc,lparg}=[];
SVMltest{lparc,lparg}=[];
SVMtp{lparc,lparg}=[];
SVMfp{lparc,lparg}=[];


for i=1:lparc
    for j=1:lparg
        cmdSVR1 = ['-t 2 -s 3',' -c ' num2str(2^parc(i)),' -g ' num2str(10^parg(j))]; % 默认类型(RBF核)
        cmdSVR2 = ['-t 3 -s 3',' -c ' num2str(2^parc(i)),' -g ' num2str(10^parg(j))]; % sigmoid核
        cmdSVM = ['-t 3 -s 0',' -c ' num2str(2^parc(i)),' -g ' num2str(10^parg(j))];
% ---------------- scoreA SVR ---------------------------
        % 下面这句代码比较简练。用来获取选择的SVM类型        
        svrDataA{i,j} = my_getSvrData(trainData,trainScoresA,testData,testScoresA,cmdSVR1);
        Acc(i,j)=svrDataA{i,j}.ccSqrt;                              
%         Acc2(i,j)=svrData{i,j}.ccOrg;
        Armse(i,j)=svrDataA{i,j}.RMSE;
        Adec{i,j}=svrDataA{i,j}.Adec;
        Atest{i,j}=svrDataA{i,j}.Atest;
        
% ---------------- scoreB SVR ---------------------------   
        svrDataB{i,j} = my_getSvrData(trainData,trainScoresB,testData,testScoresB,cmdSVR1);
        Bcc(i,j)=svrDataB{i,j}.ccSqrt;                              
%         Acc2(i,j)=svrData{i,j}.ccOrg;
        Brmse(i,j)=svrDataB{i,j}.RMSE;
        Bdec{i,j}=svrDataB{i,j}.Adec;
        Btest{i,j}=svrDataB{i,j}.Atest;
        
% ---------------- SVM  ---------------------------    
        % 下面这句代码比较简练。用来获取选择的SVM类型        
        svmData{i,j} = my_getSvmData(trainData,trainFlag,testData,testFlag,cmdSVM);
        
        SVMacc(i,j)=svmData{i,j}.acc;
        SVMsen(i,j)=svmData{i,j}.sen;
        SVMspec(i,j)=svmData{i,j}.spec;
        SVMprec(i,j)=svmData{i,j}.prec;                              
        SVMauc(i,j)=svmData{i,j}.auc;
        SVMfscore(i,j)=svmData{i,j}.fscore; 
        SVMldec{i,j}=svmData{i,j}.Ldec;
        SVMltest{i,j}=svmData{i,j}.Ltest;
        SVMtp{i,j}=svmData{i,j}.tp;
        SVMfp{i,j}=svmData{i,j}.fp;
    end
end

% 
[maxAcc,AccRmse,AccDec,AccTest,AccBest_X,AccBest_Y,minArmse]=my_findBestCc_SVR(Acc,Armse,Adec,Atest);

[maxBcc,BccRmse,BccDec,BccTest,BccBest_X,BccBest_Y,minBrmse]=my_findBestCc_SVR(Bcc,Brmse,Bdec,Btest);

[fsAcc,fsSen,fsSpec,fsPrec,fsAuc,maxFscore,fsLdec,fsLtest,fsTP,fsFP,fsBest_X,fsBest_Y,maxAuc,aucLdec,aucLtest,aucTP,aucFP,aucBest_X,aucBest_Y]=...
    my_findBestFscore_SVM(SVMacc,SVMsen,SVMspec,SVMprec,SVMauc,SVMfscore,SVMldec,SVMltest,SVMtp,SVMfp);

% Ra——scoreA的附加信息   Rb——scoreB 的附加信息    Rs—— SVM 的附加信息
Ra.maxAcc_acc=maxAcc;
Ra.maxAcc_rmse=AccRmse;
Ra.maxAcc_Ldex=AccDec;
Ra.maxAcc_Ltest=AccTest;
Ra.maxAcc_X=AccBest_X;
Ra.maxAcc_Y=AccBest_Y;

Rb.maxAcc_Bcc=maxBcc;
Rb.maxBcc_rmse=BccRmse;
Rb.maxBcc_Ldex=BccDec;
Rb.maxBcc_Ltest=BccTest;
Rb.maxBcc_X=BccBest_X;
Rb.maxBcc_Y=BccBest_Y;

Rs.maxSvmFs_auc=fsAuc;
Rs.maxSvmFs_Ldec=fsLdec;
Rs.maxSvmFs_Ltest=fsLtest;
Rs.maxSvmFs_tp=fsTP;
Rs.maxSvmFs_fp=fsFP;
Rs.maxSvmFs_X=fsBest_X;
Rs.maxSvmFs_Y=fsBest_Y;

Rs.maxAuc_auc=maxAuc;
Rs.maxAuc_Ldec=aucLdec;
Rs.maxAuc_Ltest=aucLtest;
Rs.maxAuc_tp=aucTP;
Rs.maxAuc_fp=aucFP;
Rs.maxAuc_X=aucBest_X;
Rs.maxAuc_Y=aucBest_Y;


% [maxACC.cc,maxACC.rmse,maxACC.Ldec,maxACC.Ltest,maxACC.X,maxACC.Y,minArmse]=my_findBestCc_SVR(Acc,Armse,Adec,Atest);
% 
% [maxBCC.cc,maxBCC.rmse,maxBCC.Ldec,maxBCC.Ltest,maxBCC.X,maxBCC.Y,minBrmse]=my_findBestCc_SVR(Bcc,Brmse,Bdec,Btest);
% 
% [   maxFS.acc,maxFS.sen,maxFS.spec,maxFS.prec,maxFS.auc,maxFS.maxFscore,maxFS.Ldec,maxFS.Ltest,maxFS.tp,maxFS.fp,maxFS.X,maxFS.Y,...
%     maxAUC.maxAuc,maxAUC.tp,maxAUC.fp,maxAUC.X,maxAUC.Y]=my_findBestFscore_SVM(SVMacc,SVMsen,SVMspec,SVMprec,SVMauc,SVMfscore,SVMldec,SVMltest,SVMtp,SVMfp);

end





