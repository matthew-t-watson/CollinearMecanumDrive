%
% CONSTRUCT_MAS  (Modified from original by Bert Pluymers)
%
% constructs the maximal output admissable set S for a linear system
% x(k+1)= Phi x(k) and subject to sample constraints
% defined by A_y * x <= b_y
%
%    Garbage_collection :
%
%       0 = do not remove redundant constraints
%       1 = remove redundant constraints after constructing the MAS
%       2 = remove redundant constraints during and after constructint the MAS
%          (speeds up the algorithm in some cases)
%
% Return values :
%
%    A_S, b_s : matrices defining the constructed invariant set S
%                   S = {x | A_S * x <= b_S}
%
function [varargout] = construct_mas(Phi,A_y,b_y,garbage_collection,ns, small, verbosity, forceRegen)

persistent prevArgs

if ~isempty(prevArgs) && ~forceRegen
    if isequal(Phi, prevArgs.Phi) && isequal(A_y, prevArgs.A_y) && isequal(b_y, prevArgs.b_y) ...
            && isequal(garbage_collection, prevArgs.garbage_collection) && isequal(small, prevArgs.small) ...
            && prevArgs.complete == true
        varargout{1} = prevArgs.A_S;
        varargout{2} = prevArgs.b_S;
        if verbosity >= 1
            disp('construct_mas input arguments unchanged, reusing previous result');
        end
        return;
    end
end

prevArgs.complete = false;
prevArgs.Phi = Phi;
prevArgs.A_y = A_y;
prevArgs.b_y = b_y;
prevArgs.garbage_collection = garbage_collection;
prevArgs.small = small;

success = false;

options = optimset('Display','off');
options.MaxIterations = 1E6;

% generate initial guess for MAS (sample constraints)
A_S     = A_y;
b_S     = b_y;
depth_S = zeros(size(b_S));
if verbosity >= 2
    fprintf('Intialization, #constraints =%4.0f\n',size(A_S,1));
end

% go over the rows of A_S matrix, and add constraints when necessary until
% it is invariant
row=1;
iter=0;
while row <= size(A_S,1)
    iter=iter+1;
    
    try
        options.Algorithm = 'dual-simplex';
        [x, fval,exitflag] = linprog(-A_S(row,1:end-ns)*Phi(1:end-ns,1:end-ns),A_S(:,1:end-ns),b_S,[],[],[],[],[],options);
    catch
        options.Algorithm = 'interior-point-legacy';
        if verbosity
            disp('dual-simplex threw error, switching to interior-point-legacy');
        end
        try
            [x, fval,exitflag] = linprog(-A_S(row,1:end-ns)*Phi(1:end-ns,1:end-ns),A_S(:,1:end-ns),b_S,[],[],[],[],[],options);
        catch err
            error([err.message '\ninterior-point-legacy also threw error, failed to derive MAS'],'char');
        end
    end
    if exitflag==-3
        %           disp('Possible problem with admissible set - solution is unbounded');
        %          disp(['size of A_S is currently ',num2str(length(b_S))])
        fval=-b_S(row,:)-10;
    end
    if fval<-b_S(row,:)-small
        if verbosity >= 2
            fprintf('Constraint added, #constraints =%4.0f\n',size(A_S,1)+1);
        end
        A_S     = [A_S; A_S(row,:)*Phi];
        b_S     = [b_S; b_S(row,:)];
        
        % Remove rounding errors. Currently doesn't yield a symmetrical MAS
        % as expected.
%         A_S(abs(A_S)<1E-10) = 0;
%         b_S(abs(b_S)<1E-10) = 0;
        depth_S = [depth_S; depth_S(row,:)+1];
    end
    
    row = row + 1;
    if (garbage_collection>1) && (mod(iter,10)==0)
        for j=size(A_S,1):-1:1
            try
                options.Algorithm = 'dual-simplex';
                [x, fval,exitflag] = linprog(-A_S(j,1:end-ns),A_S([1:j-1 j+1:end],1:end-ns),b_S([1:j-1 j+1:end],:),[],[],[],[],[],options);
            catch
                options.Algorithm = 'interior-point-legacy';
                if verbosity >= 1
                    disp('dual-simplex threw error, switching to interior-point-legacy');
                end
                try
                    [x, fval,exitflag] = linprog(-A_S(j,1:end-ns),A_S([1:j-1 j+1:end],1:end-ns),b_S([1:j-1 j+1:end],:),[],[],[],[],[],options);
                catch err
                    error([err.message '\ninterior-point-legacy also threw error, failed to derive MAS'],'char');
                end
                    
            end
            if and(fval>-b_S(j,:)-small,exitflag==1)
                if verbosity >= 2
                    fprintf('Constraint %4.0f removed, #constraints =%4.0f\n',j,size(A_S,1)-1);
                end
                A_S     = A_S([1:j-1 j+1:end],:);
                b_S     = b_S([1:j-1 j+1:end],:);
                depth_S = depth_S([1:j-1 j+1:end],:);
                if j<row
                    row=row-1;
                end
            end
        end
    end
end

if garbage_collection>0
    %fprintf('Cleaning up\n');
    % clean up invariant set (remove redundant constraints)
    for i=size(A_S,1):-1:1;
        [x, fval,exitflag] = linprog(-A_S(i,1:end-ns),A_S([1:i-1 i+1:end],1:end-ns),b_S([1:i-1 i+1:end],:),[],[],[],[],[],options);
        try
            options.Algorithm = 'dual-simplex';
            [x, fval,exitflag] = linprog(-A_S(i,1:end-ns),A_S([1:i-1 i+1:end],1:end-ns),b_S([1:i-1 i+1:end],:),[],[],[],[],[],options);
        catch
            options.Algorithm = 'interior-point-legacy';
            if verbosity >= 1
                disp('dual-simplex threw error, switching to interior-point-legacy');
            end
            try
                [x, fval,exitflag] = linprog(-A_S(i,1:end-ns),A_S([1:i-1 i+1:end],1:end-ns),b_S([1:i-1 i+1:end],:),[],[],[],[],[],options);
            catch err
                error([err.message '\ninterior-point-legacy also threw error, failed to derive MAS'],'char');
            end
        end
        if and(fval>-b_S(i,:)-small,exitflag==1)
            if verbosity >= 2
                fprintf('Constraint %4.0f removed, #constraints =%4.0f\n',i,size(A_S,1)-1);
            end
            A_S     = A_S([1:i-1 i+1:end],:);
            b_S     = b_S([1:i-1 i+1:end],:);
            depth_S = depth_S([1:i-1 i+1:end],:);
        end
    end
end


prevArgs.A_S = A_S;
prevArgs.b_S = b_S;
prevArgs.complete = true;

varargout{1} = A_S;
varargout{2} = b_S;
if nargout>2
    varargout{3} = depth_S;
end

