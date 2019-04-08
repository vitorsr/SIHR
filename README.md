## About

An ongoing effort of developing new and implementing established single image highlight removal (SIHR) methods on MATLAB.

I welcome and encourage additions upon review.

*Disclaimer: this repository is for educational purposes only.*

## Usage

Run `SIHR.m` for path setup.

Run `help SIHR` for (minimal) documentation.

The environment this repository is being developed is:

- MATLAB R2019a;
- [Image Processing Toolbox](https://www.mathworks.com/products/image.html).

The repository is structured as follows:

    SIHR\
      ↳ img\
          ↳ Test images.
      ↳ Tan2005\
          ↳ Implementation of Tan's zHighlightRemoval class [3].
            Available at (C++):
            http://tanrobby.github.io/code/highlight.zip.
      ↳ Yoon2006\
          ↳ Implementation of Yoon's 2006 method [4].
      ↳ Shen2008\
          ↳ Code for [5].
            Also available at (MATLAB):
            http://ivlab.org/publications/PR2008_code.zip.
      ↳ Shen2009\
          ↳ Code for [6].
      ↳ Yang2010\
          ↳ Implementation of Yang's qx_highlight_removal_bf method [7, 10].
            Formerly available at (C++):
            http://www.cs.cityu.edu.hk/~qiyang/publications/code/eccv-10.zip.
      ↳ Akashi2015\
          ↳ Direct implementation of [11].
      ↳ Yamamoto2017\
          ↳ Implementation of improvements in [12].

Feel free to create either an issue or a PR or contact me for any questions, comments, or improvements.

Below are listed references for works herein present and a couple survey papers for further reading.

## References

1. A. Artusi, F. Banterle, and D. Chetverikov, “A Survey of Specularity Removal Methods,” Computer Graphics Forum, vol. 30, no. 8, pp. 2208–2230, Aug. 2011 [Online]. Available: http://dx.doi.org/10.1111/J.1467-8659.2011.01971.X;

2. H. A. Khan, J.-B. Thomas, and J. Y. Hardeberg, “Analytical Survey of Highlight Detection in Color and Spectral Images,” in Lecture Notes in Computer Science, Springer International Publishing, 2017, pp. 197–208 [Online]. Available: http://dx.doi.org/10.1007/978-3-319-56010-6_17;

3. R. T. Tan and K. Ikeuchi, “Separating reflection components of textured surfaces using a single image,” IEEE Transactions on Pattern Analysis and Machine Intelligence, vol. 27, no. 2, pp. 178–193, Feb. 2005 [Online]. Available: http://dx.doi.org/10.1109/TPAMI.2005.36;

4. K. Yoon, Y. Choi, and I. S. Kweon, “Fast Separation of Reflection Components using a Specularity-Invariant Image Representation,” in 2006 International Conference on Image Processing, 2006 [Online]. Available: http://dx.doi.org/10.1109/ICIP.2006.312650;

5. H.-L. Shen, H.-G. Zhang, S.-J. Shao, and J. H. Xin, “Chromaticity-based separation of reflection components in a single image,” Pattern Recognition, vol. 41, no. 8, pp. 2461–2469, Aug. 2008 [Online]. Available: http://dx.doi.org/10.1016/J.PATCOG.2008.01.026;

6. H.-L. Shen and Q.-Y. Cai, “Simple and efficient method for specularity removal in an image,” Applied Optics, vol. 48, no. 14, p. 2711, May 2009 [Online]. Available: http://dx.doi.org/10.1364/AO.48.002711;

7. R. Grosse, M. K. Johnson, E. H. Adelson, and W. T. Freeman, “Ground truth dataset and baseline evaluations for intrinsic image algorithms,” in 2009 IEEE 12th International Conference on Computer Vision, 2009 [Online]. Available: http://dx.doi.org/10.1109/ICCV.2009.5459428;

8. Q. Yang, S. Wang, and N. Ahuja, “Real-Time Specular Highlight Removal Using Bilateral Filtering,” in Computer Vision – ECCV 2010, Springer Berlin Heidelberg, 2010, pp. 87–100 [Online]. Available: http://dx.doi.org/10.1007/978-3-642-15561-1_7;

9. H.-L. Shen and Z.-H. Zheng, “Real-time highlight removal using intensity ratio,” Applied Optics, vol. 52, no. 19, p. 4483, Jun. 2013 [Online]. Available: http://dx.doi.org/10.1364/AO.52.004483;

10. Q. Yang, J. Tang, and N. Ahuja, “Efficient and Robust Specular Highlight Removal,” IEEE Transactions on Pattern Analysis and Machine Intelligence, vol. 37, no. 6, pp. 1304–1311, Jun. 2015 [Online]. Available: http://dx.doi.org/10.1109/TPAMI.2014.2360402;

11. Y. Akashi and T. Okatani, “Separation of reflection components by sparse non-negative matrix factorization,” Computer Vision and Image Understanding, vol. 146, pp. 77–85, May 2016 [Online]. Available: http://dx.doi.org/10.1016/j.cviu.2015.09.001;

12. T. Yamamoto, T. Kitajima, and R. Kawauchi, “Efficient improvement method for separation of reflection components based on an energy function,” in 2017 IEEE International Conference on Image Processing (ICIP), 2017 [Online]. Available: http://dx.doi.org/10.1109/ICIP.2017.8297078;
