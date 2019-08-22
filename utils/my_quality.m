method = { ...
    @Tan2005, @Yoon2006, @Shen2008, @Shen2009, ...
    @Yang2010, @Shen2013, @Akashi2016};

name = {'animals', 'cups', 'fruit', 'masks'};
gt = '_gt';
ext = '.bmp';

image = cell(4, 1);
truth = cell(4, 1);

for i = 1:length(name)
    image{i} = im2double(imread([name{i}, ext]));
    truth{i} = im2double(imread([name{i}, gt, ext]));
end

my_psnr = zeros(length(method), length(name));
my_ssim = zeros(length(method), length(name));

for m = 1:length(method)
    disp(['Method ', func2str(method{m})])
    for i = 1:length(name)
        disp(['  Image ', name{i}])
        I_d = feval(method{m}, image{i});
        my_psnr(m, i) = psnr(I_d, truth{i});
        my_ssim(m, i) = ssim(I_d, truth{i});
    end
end

disp('my_psnr =')
disp(round(10*my_psnr)/10)

disp('my_ssim =')
disp(round(1000*my_ssim)/1000)
