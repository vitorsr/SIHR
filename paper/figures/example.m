I = im2double(imread('fruit.bmp'));
I_d = Yang2010(I);
figure(1)
subplot(1, 3, 1), imshow(I), xlabel('(a)', 'FontName', 'Helvetica', 'FontSize', 8, 'VerticalAlignment', 'bottom')
subplot(1, 3, 2), imshow(I_d), xlabel('(b)', 'FontName', 'Helvetica', 'FontSize', 8, 'VerticalAlignment', 'bottom')
subplot(1, 3, 3), imshow(I-I_d), xlabel('(c)', 'FontName', 'Helvetica', 'FontSize', 8, 'VerticalAlignment', 'bottom')
set(gcf, 'PaperUnits', 'inches')
set(gcf, 'PaperPosition', [0, 0, 5.35, 3])
print('example.png', '-dpng', '-r300')
% convert figure1.png -trim figure1.png
