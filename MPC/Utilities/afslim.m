function varargout= afslim(varargin)
%This is a tool for constructing an anonymous function which carries only
%external parameters specified by the user.
%
%    anonFunc = afslim(fun,a,b,c,... )
%    anonFunc = afslim(func2str(fun),a,b,c,... )
%
%Here, fun() is an anonymous function and a,b,c,... are extra parameters that
%it needs to refer to. As the second syntax shows, it can also be specified in
%string form.
% 
% 
%EXAMPLE: The following code (important - must be run as an mfile function, not from 
%the command line!!) generates two files containing an anonymous function with
%the same functional behavior. However, tst1.mat consumes 259 MB whereas tst2.mat
%consumes only 1 KB.
% 
%    function test
% 
%         b=2;
% 
%          fun1=@(x)x+b; 
%          fun2=afslim(fun1,b);   %alternatively fun2=afslim('@(x)x+b', b)
% 
%         b=rand(6000); 
% 
%       save tst1 fun1 
%       save tst2 fun2 
% 
%    end  


 
 for iuo99753fqhewsgju__7921zqar=2:length(varargin)
     
  %iuo99753fqhewsgju__7921zqar : a deliberately unlikely variable name as the
  %loop counter, so as not to conflict with variable names passed by the user.   
     
     
   eval( [inputname(iuo99753fqhewsgju__7921zqar)...
          ' = varargin{' num2str(iuo99753fqhewsgju__7921zqar) '};']  );      
     
 end

 clear iuo99753fqhewsgju__7921zqar
 
 varargin(2:end)=[];
 
 if ~ischar(varargin{1}), varargin{1}=func2str(varargin{1}); end
 
 varargout{1}=eval( varargin{1} );
 
 clear varargin
