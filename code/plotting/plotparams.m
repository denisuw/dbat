function hh=plotparams(s,e,varargin)
%PLOTPARAMS Plot bundle iteration parameters.
%
%   PLOTPARAMS(S,E), where S is a struct returned by PROB2DBATSTRUCT and E
%   is a struct returned by BUNDLE, plots the iteration trace of the
%   parameters estimated by BUNDLE.
%
%   

h=nan(3,1);

[ixIO,ixEO,ixOP]=indvec([nnz(s.cIO),nnz(s.cEO),nnz(s.cOP)]);

if any(s.cIO)
    ixPos=double(s.cIO);
    ixPos(s.cIO)=ixIO;
    
    % IO parameter plot.
    h(1)=tagfigure('paramplot_io');
    fig=h(1);
    clf(fig);

    ax=subplot(3,1,1,'parent',fig);
    cla(ax);
    cc=get(ax,'colororder');
    % Legend strings.
    lgs={};
    % Line styles.
    ls={'-','--','-.'};
    
    % For each camera.
    for ci=1:size(s.IO,2)
        % Create array with fixed focal length, principal point.
        fp=repmat(s.IO(1:3,ci),1,size(e.trace,2));
        % Update with estimated values.
        ixp=ixPos(1:3,ci);
        fp(s.cIO(1:3,ci),:)=e.trace(ixp(s.cIO(1:3,ci)),:);
        % Flip y coordinate.
        v=diag([1,-1,1])*fp;
        % Line style and legend strings.
        ls={'-','--','-.'};
        fps={'f','px','py'};
        for i=1:size(v,1)
            if size(s.IO,2)==1
                color=cc(i,:);
                lgs{end+1}=fps{i};
            else
                color=cc(rem(ci-1,size(cc,1))+1,:);
                lgs{end+1}=sprintf('%s-%d',fps{i},ci);
            end
            line(0:size(e.trace,2)-1,v(i,:),'parent',ax,'linestyle',ls{i},...
                 'marker','x','color',color);
        end
        legend(lgs);
    end
    title(ax,'Focal length, principal point');
    
    ax=subplot(3,1,2,'parent',fig);
    % Legend strings.
    lgs={};
    % For each camera.
    for ci=1:size(s.IO,2)
        % Create array with K1-K3 parameters.
        K=repmat(s.IO(4:6,ci),1,size(e.trace,2));
        % Update with estimated values.
        ixp=ixPos(4:6,ci);
        K(s.cIO(4:6,ci),:)=e.trace(ixp(s.cIO(4:6,ci)),:);
        % Scale K values.
        v=diag(100.^(0:size(K,1)-1))*K;
        for i=1:size(v,1)
            if i==1
                prefix='';
            else
                prefix=sprintf('10^%d',(i-1)*2);
            end
            if size(s.IO,2)==1
                color=cc(i,:);
                lgs{end+1}=sprintf('%sK%d',prefix,i);
            else
                color=cc(rem(ci-1,size(cc,1))+1,:);
                lgs{end+1}=sprintf('%sK%d-%d',prefix,i,ci);
            end
            
            line(0:size(e.trace,2)-1,v(i,:),'parent',ax,'linestyle',ls{i},...
                 'marker','x','color',color);
        end
        legend(lgs);
    end
    title(ax,'Radial distortion');
    
    ax=subplot(3,1,3,'parent',fig);
    % Legend strings.
    lgs={};
    % For each camera.
    for ci=1:size(s.IO,2)
        % Create array with P1-P2 parameters.
        P=repmat(s.IO(7:8,ci),1,size(e.trace,2));
        % Update with estimated values.
        ixp=ixPos(7:8,ci);
        P(s.cIO(7:8,ci),:)=e.trace(ixp(s.cIO(7:8,ci)),:);
        for i=1:size(P,1)
            if size(s.IO,2)==1
                color=cc(i,:);
                lgs{end+1}=sprintf('P%d',i);
            else
                color=cc(rem(ci-1,size(cc,1))+1,:);
                lgs{end+1}=sprintf('P%d-%d',i,ci);
            end

            line(0:size(e.trace,2)-1,P(i,:),'parent',ax,'linestyle',ls{i},...
                 'marker','x','color',color);
        end
        legend(lgs);
    end
    title(ax,'Tangential distortion');
end

if any(s.cEO)
    ixPos=double(s.cEO);
    ixPos(s.cEO)=ixEO;

    % EO parameter plot.
    h(2)=tagfigure('paramplot_eo');
    fig=h(2);
    clf(fig);

    ax=subplot(2,1,1,'parent',fig);
    cla(ax);
    cc=get(ax,'colororder');
    % Legend strings.
    lgs={};
    % Line styles.
    ls={'-','--','-.'};

    % Callback to clear all highlights in figure and highlight lines
    % corresponding to clicked line.
    cb=@highlight;
    
    % Plot each coordinate as the outer loop to get a better legend.
    for i=1:3
        % For each camera.
        for ci=1:size(s.EO,2)
            % Create array with camera centers.
            c=repmat(s.EO(1:3,ci),1,size(e.trace,2));
            % Update with estimated values.
            ixp=ixPos(1:3,ci);
            c(s.cEO(1:3,ci),:)=e.trace(ixp(s.cEO(1:3,ci)),:);
            % Line style and legend strings.
            ls={'-','--','-.'};
            fps={'X0','Y0','Z0'};
            color=cc(rem(ci-1,size(cc,1))+1,:);
            if i==1
                lgs{end+1}=sprintf('C%d',ci);
            end
            line(0:size(e.trace,2)-1,c(i,:),'parent',ax,'linestyle',ls{i},...
                 'marker','x','color',color,...
                 'tag',sprintf('%c0-%d',abs('X')-1+i,ci),...
                 'userdata',ci,'buttondownfcn',cb);
        end
        if i==1
            [legh,objh,outh,outm]=legend(lgs);
            % First comes text handles, then line handles.
            lineH=reshape(objh(size(s.EO,2)+1:end),2,[]);
            % Set lines to highlight when selected.
            set(lineH','selectionhighlight','on');
            for j=1:size(s.EO,2)
                set(lineH(:,j),'userdata',j,'buttondownfcn',cb,'hittest','on');
            end
        end
    end
    title(ax,'Camera center');
    
    ax=subplot(2,1,2,'parent',fig);
    % Angle strings.
    aStrs={'\omega','\phi','\kappa'};
    
    % For each camera.
    for ci=1:size(s.EO,2)
        % Create array with K1-K3 parameters.
        angles=repmat(s.EO(4:6,ci),1,size(e.trace,2));
        % Update with estimated values.
        ixp=ixPos(4:6,ci);
        angles(s.cEO(4:6,ci),:)=e.trace(ixp(s.cEO(4:6,ci)),:);
        % Convert to degrees.
        angles=angles*180/pi;
        for i=1:size(angles,1)
            color=cc(rem(ci-1,size(cc,1))+1,:);
            
            line(0:size(e.trace,2)-1,angles(i,:),'parent',ax,...
                 'linestyle',ls{i}, ... 
                 'marker','x','color',color,...
                 'tag',sprintf('%s-%d',aStrs{i},ci),'userdata',ci,...
                 'buttondownfcn',cb);

        end
    end
    title(ax,'Euler angles [degrees]');
end

function highlight(obj,event)

if nargin<1, obj=gcbo; end
fig=gcbf;

% Get object number.
num=get(obj,'userdata');

% All objects.
all=findobj(fig,'type','line');
% All matching objects.
sel=findobj(all,'flat','userdata',num);

% Clear any previous highlights.
set(all,'selected','off','linewidth',0.5);
% Select and set thick lines.
set(sel,'selected','on','linewidth',2);

% Move selected object to the front.

% Get all axes that are parents to selected objects.
ax=unique(cell2mat(get(sel,'parent')));
for i=1:length(ax)
    if strcmp(get(ax(i),'type'),'axes')
        ch=get(ax(i),'children');
        % Find out which of the selected objects are in this axes.
        j=ismember(ch,sel);
        [dummy,k]=sort(j);
        set(ax(i),'children',ch(k));
    end
end

