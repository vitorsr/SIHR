% run([userpath '\SIHR\SIHR.m'])
J = im2double(imread('fruit.bmp'));
J_d = Yang2010(J);
figure(1)
subplot(1, 3, 1), imshow(J), xlabel('(a)', 'FontName', 'Times', 'FontSize', 8, 'VerticalAlignment', 'bottom')
subplot(1, 3, 2), imshow(J_d), xlabel('(b)', 'FontName', 'Times', 'FontSize', 8, 'VerticalAlignment', 'bottom')
subplot(1, 3, 3), imshow(J-J_d), xlabel('(c)', 'FontName', 'Times', 'FontSize', 8, 'VerticalAlignment', 'bottom')
% print -depsc example.eps
