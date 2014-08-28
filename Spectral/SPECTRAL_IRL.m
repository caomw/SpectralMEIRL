% Spectral method for Multiple Expert IRL
%
function [sol] = SPECTRAL_IRL(trajs, mdp, irlOpts)

%nClusters = irlOpts.nClusters;
nTrajs = size(trajs, 1);

sol.weight   = [];

TF = calBuildTF(trajs, mdp);
trajInfo = calSVD(TF);
%wL = trajInfo.v(1,:)'

%TODO: cluster using TF*v
sol.u = trajInfo.u;
sol.singular = trajInfo.singular;
sol.v = trajInfo.v;
%TF.featExp*trajInfo.v
[sol.belongTo, nClusters] = calCluster(trajInfo.u,0.08)
% 
% nClusters = 10;
% clusterId  =[];
% trajNum = nTrajs/nClusters;
% for i  = 1:nClusters
%     clusterId  = cat(1, clusterId, repmat(i, trajNum, 1));
% end
% sol.belongTo = clusterId;
%

% reward function for each cluster
mFeatExp = calMergeFeatExp(TF.featExp,sol.belongTo, nClusters);
priorMatrix = eye(nClusters);
p1 = 1;
p2 = (1-p1)/(nClusters-1);
for i = 1:nClusters
    for j = 1:nClusters
        if i == j
            priorMatrix(i,j) = p1;
        else
            priorMatrix(i,j) = p2;
        end
    end
end
%priorMatrix = [0.8 0.1 0.1; 0.1 0.8 0.1; 0.1 0.1 0.8];
trajRewawrd = priorMatrix*pinv(mFeatExp)'
for m = 1:nClusters
    wL = trajRewawrd(m,:)';
    sol.weight = cat(2, sol.weight, wL);
end

end