function [f,J,JJ]=brown_euler_cam2(x,s)
%BROWN_EULER_CAM2 Residual function for the Brown camera model with Euler angles.
%
%   R=BROWN_EULER_CAM2(X,S) returns the residual vector R of the camera
%   network defined in S evaluated with the approximate values in X.
%
%   Use [R,J]=... or [R,J,JJ]=... to get the analytical Jacobian J
%   and the numerical Jacobian JJ.
%
%   The internal camera model is from Brown (1971) with K1, K2, K3,
%   P1, and P2. The external orientation uses Euler omega-phi-kappa
%   angles.  The values of S.estIO, S.estEO, and S.estOP indicate what
%   parameters in S.IO, S.EO, and S.OP, respectively are unknown.
%
%   References: Brown (1971), "Close-range camera calibration".
%       Photogrammetric Engineering, 37(8): 855-866.
%
%   See also PROB2DBATSTRUCT, BUNDLE, GAUSS_NEWTON_ARMIJO,
%       LEVENBERG_MARQUARDT, LEVENBERG_MARQUARDT_POWELL.


% Create index vectors for unknown parameters.
[ixIO,ixEO,ixOP,n]=indvec([nnz(s.estIO),nnz(s.estEO),nnz(s.estOP)]);

% Copy the current approximations of the unknown values.
IO=s.IO;
IO(s.estIO)=x(ixIO);
EO=s.EO;
EO(s.estEO)=x(ixEO);
OP=s.OP;
OP(s.estOP)=x(ixOP);

if (nargout>2)
    % Numerical approximation of Jacobian (for debugging only).
    JJ=jacapprox(mfilename,x,1e-6,{s});
end

if all(s.IOdistModel==1) % backward/photogrammetric
    if (nargout<2)
        % Only residual vector requested.
    
        % Project into pinhole camera.
        xy=reshape(pm_multieulerpinhole1(IO,s.nK,s.nP,EO,s.cams,OP,s.vis),2,[]);

        % Convert measured points from pixels to mm and flip y coordinate.
        m=diag([1,-1])*multiscalepts(s.markPts,IO,s.nK,s.nP,s.ptCams,size(IO,2));
        
        % Compute lens distortion for all measured point.
        ld=pm_multilens1(m,IO,s.nK,s.nP,s.ptCams,size(IO,2));
        
        % Remove lens distortion from measured points.
        ptCorr=m-ld;
        
        % Compute residual for image observations.
        fObs=xy-ptCorr;

        % Compute residual for prior observations.
        fPre=pm_preobs(x,s);

        % Combine residuals.
        f=[fObs(:);fPre(:)];
    else
        % Project into pinhole camera.
        [xy,dIO1,dEO,dOP]=pm_multieulerpinhole1(IO,s.nK,s.nP,EO,s.cams,OP, ...
                                                s.vis,s.estIO,s.estEO,s.estOP);
        xy=reshape(xy,2,[]);
	
        % Convert measured points from pixels to mm and flip y coordinate.
        m=diag([1,-1])*multiscalepts(s.markPts,IO,s.nK,s.nP,s.ptCams,...
                                     size(IO,2));

        % Compute lens distortion for all measured point.
        [ld,dIO2]=pm_multilens1(m,IO,s.nK,s.nP,s.ptCams,size(IO,2),s.estIO);

        % Remove lens distortion from measured points.
        ptCorr=m-ld;
        
        % Compute residual for image observations.
        fObs=xy-ptCorr;

        % Compute residual for prior observations.
        [fPre,Jpre]=pm_preobs(x,s);

        f=[fObs(:);fPre(:)];
	
        J=[dIO1-dIO2,dEO,dOP;Jpre];
    end
elseif all(s.IOdistModel==-1) % forward/computer vision
    if (nargout<2)
        % Only residual vector requested.
    
        % Project into pinhole camera.
        xy=reshape(pm_multieulerpinhole1(IO,s.nK,s.nP,EO,s.cams,OP,s.vis),2,[]);

        % Convert measured points from pixels to mm and flip y coordinate.
        m=diag([1,-1])*multiscalepts(s.markPts,IO,s.nK,s.nP,s.ptCams,size(IO,2));
        
        % Compute lens distortion for projected points.
        ld=pm_multilens1(reshape(xy,2,[]),IO,s.nK,s.nP,s.ptCams,size(IO,2));

        % Add lens distortion to projected points.
        ptDist=xy+ld;
        
        fPre=pm_preobs(x,s);
    
        f=[ptDist(:)-m(:);fPre];
    else
        % Numerical Jacobian for the time being.
        f=feval(mfilename,x,s);
        J=jacapprox(mfilename,x,1e-6,{s});
        return;

        % % Project into pinhole camera.
        % [xy,dIO1,dEO,dOP]=pm_multieulerpinhole1(IO,s.nK,s.nP,EO,s.cams,OP, ...
        %                                         s.vis,s.estIO,s.estEO,s.estOP);
	
        % % Remove lens distortion from measured points.
        % [ptCorr,dIO2]=pm_multilenscorr1(diag([1,-1])*s.markPts,IO,s.nK,s.nP, ...
        %                                 s.ptCams,size(IO,2),s.estIO);

        % [fPre,Jpre]=pm_preobs(x,s);

        % f=[xy(:)-ptCorr(:);fPre];
	
        % J=[dIO1-dIO2,dEO,dOP;Jpre];
    end
else
    error('Mixed lens distortion models not implemented.');
end