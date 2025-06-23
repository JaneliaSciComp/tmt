function build()

% get the directory where this file lives
thisScriptFileName=mfilename('fullpath');
thisScriptDirName=fileparts(thisScriptFileName);
thisScriptDirParts=split_on_filesep(thisScriptDirName);
  % a cell array with each dir an element
groundswellRootParts=thisScriptDirParts(1:end);
groundswellRootDirName=combine_with_filesep(groundswellRootParts);

% just put the executable in the dir with the build script
exeDirName=thisScriptDirName;

% get the abs path to the home dir
this_dir_name=pwd();
cd('~');
home_dir_name=pwd();
cd(this_dir_name);

% Call the mcc to do the compilation
fprintf('Invoking mcc...\n');
mcc('-o','Groundswell', ...
    '-m', ...
    '-d',exeDirName, ...
    '-I',groundswellRootDirName,...
    '-I',fullfile(home_dir_name,'taylor_matlab_toolbox/113'), ...
    '-v', ...
    fullfile(groundswellRootDirName,'groundswell.m'));

fprintf('Clearing out intermediate/useless files...\n');
file_name=fullfile(exeDirName,'mccExcludedFiles.log');
if exist(file_name,'file')
  delete(file_name);
end
file_name=fullfile(exeDirName,'readme.txt');
if exist(file_name,'file')
  delete(file_name);
end

fprintf('Done building.\n');

end





function path=combine_with_filesep(path_as_array)
  % combine a cell array of dir names into a single path name
  n=length(path_as_array);
  if n>0
    path=path_as_array{1};
    for i=2:n
      path=[path filesep path_as_array{i}];  %#ok
    end
  end
end





function path_as_array=split_on_filesep(path)
  % split a path on filesep into a cell array of single dir names
  
  % check for empty input
  if isempty(path)
    path_as_array=cell(0,1);
    return;
  end
  
  % trim a trailing fileseparator
  if path(end)==filesep
    path=path(1:end-1);
  end
  
  i_pathsep=strfind(path,filesep);
  n=length(i_pathsep)+1;
  path_as_array=cell(n,1);
  if n>0
    if n==1
      path_as_array{1}=path;
    else
      % if here, n>=2
      path_as_array{1}=path(1:i_pathsep(1)-1);
      for i=2:(n-1)
        path_as_array{i}=path(i_pathsep(i-1)+1:i_pathsep(i)-1);
      end
      path_as_array{n}=path(i_pathsep(n-1)+1:end);
    end
  end
end

