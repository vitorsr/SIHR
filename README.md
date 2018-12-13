## About

An ongoing effort of developing new and implementing established single image highlight removal (SIHR) methods on MATLAB.

I welcome and encourage additions upon review.

*Disclaimer: this repository is for educational purposes only.*

## Usage

Run `SIHR.m` for path setup.

Run `help SIHR` for documentation.

The environment this project is being developed is:

- MATLAB R2018b;
- [Image Processing Toolbox](https://www.mathworks.com/products/image.html).

The project is structured like so:

    SIHR\
         ↳ img\
               ↳ Test images;
         ↳  qx\
               ↳ Implementation of Yang's qx_highlight_removal_bf method [7];
         ↳   v\
               ↳ Personal folder;
         ↳   z\
               ↳ Implementation of Tan's zHighlightRemoval class [3].

Feel free to create either an issue or a PR or contact me for any questions, comments, or improvements.

Below are listed major references and recognized works that I plan on studying.

## References

1. A. Artusi, F. Banterle, and D. Chetverikov, “A Survey of Specularity Removal Methods,” Computer Graphics Forum, vol. 30, no. 8, pp. 2208–2230, Aug. 2011 [Online]. Available: http://dx.doi.org/10.1111/J.1467-8659.2011.01971.X;

2. H. A. Khan, J.-B. Thomas, and J. Y. Hardeberg, “Analytical Survey of Highlight Detection in Color and Spectral Images,” in Lecture Notes in Computer Science, Springer International Publishing, 2017, pp. 197–208 [Online]. Available: http://dx.doi.org/10.1007/978-3-319-56010-6_17;

3. R. T. Tan and K. Ikeuchi, “Separating reflection components of textured surfaces using a single image,” IEEE Transactions on Pattern Analysis and Machine Intelligence, vol. 27, no. 2, pp. 178–193, Feb. 2005 [Online]. Available: http://dx.doi.org/10.1109/TPAMI.2005.36;

4. K. Yoon, Y. Choi, and I. S. Kweon, “Fast Separation of Reflection Components using a Specularity-Invariant Image Representation,” in 2006 International Conference on Image Processing, 2006 [Online]. Available: http://dx.doi.org/10.1109/ICIP.2006.312650;

5. H.-L. Shen, H.-G. Zhang, S.-J. Shao, and J. H. Xin, “Chromaticity-based separation of reflection components in a single image,” Pattern Recognition, vol. 41, no. 8, pp. 2461–2469, Aug. 2008 [Online]. Available: http://dx.doi.org/10.1016/J.PATCOG.2008.01.026;

6. H.-L. Shen and Q.-Y. Cai, “Simple and efficient method for specularity removal in an image,” Applied Optics, vol. 48, no. 14, p. 2711, May 2009 [Online]. Available: http://dx.doi.org/10.1364/AO.48.002711;

7. Q. Yang, S. Wang, and N. Ahuja, “Real-Time Specular Highlight Removal Using Bilateral Filtering,” in Computer Vision – ECCV 2010, Springer Berlin Heidelberg, 2010, pp. 87–100 [Online]. Available: http://dx.doi.org/10.1007/978-3-642-15561-1_7;

8. H. Kim, H. Jin, S. Hadap, and I. Kweon, “Specular Reflection Separation Using Dark Channel Prior,” in 2013 IEEE Conference on Computer Vision and Pattern Recognition, 2013 [Online]. Available: http://dx.doi.org/10.1109/CVPR.2013.192;

9. H.-L. Shen and Z.-H. Zheng, “Real-time highlight removal using intensity ratio,” Applied Optics, vol. 52, no. 19, p. 4483, Jun. 2013 [Online]. Available: http://dx.doi.org/10.1364/AO.52.004483;

10. J. Yang, L. Liu, and S. Z. Li, “Separating Specular and Diffuse Reflection Components in the HSI Color Space,” in 2013 IEEE International Conference on Computer Vision Workshops, 2013 [Online]. Available: http://dx.doi.org/10.1109/ICCVW.2013.122;

11. J. Yang, Z. Cai, L. Wen, Z. Lei, G. Guo, and S. Z. Li, “A New Projection Space for Separation of Specular-Diffuse Reflection Components in Color Images,” in Computer Vision – ACCV 2012, Springer Berlin Heidelberg, 2013, pp. 418–429 [Online]. Available: http://dx.doi.org/10.1007/978-3-642-37447-0_32;

12. Q. Yang, J. Tang, and N. Ahuja, “Efficient and Robust Specular Highlight Removal,” IEEE Transactions on Pattern Analysis and Machine Intelligence, vol. 37, no. 6, pp. 1304–1311, Jun. 2015 [Online]. Available: http://dx.doi.org/10.1109/TPAMI.2014.2360402.
