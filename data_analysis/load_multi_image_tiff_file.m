function stack = load_multi_image_tiff_file(file_name)

info=imfinfo(file_name);
n_frame=length(info);
for i=1:n_frame
  frame=imread(file_name,'info',info,'index',i);
  if i==1
    [n_row,n_col]=size(frame);
    stack=zeros(n_row,n_col,n_frame,'uint16');
  end
  stack(:,:,i)=frame;
end
