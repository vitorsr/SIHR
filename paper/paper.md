---
title: 'SIHR: a MATLAB/GNU Octave toolbox for single image highlight removal'
tags:
  - blind source separation
  - feature extraction
  - gnu octave
  - image color analysis
  - image enhancement
  - image processing
  - image texture analysis
  - matlab
authors:
  - name: Vítor S. Ramos
    orcid: 0000-0002-7583-5577
    affiliation: 1
affiliations:
 - name: Federal University of Rio Grande do Norte
   index: 1
date: 13 August 2019
bibliography: paper.bib
---

# Summary

Single image highlight removal (SIHR) refers to an open problem in computer vision concerning separation of diffuse and specular reflection components from a single image [@Tan2014]. It is an intrinsic image decomposition, so it has several applications. Recently, there was an interest renewal in this problem for the objective of image enhancement in visual display systems such as TVs [@Yamamoto2017].

![Example decomposition. (a\) Input, (b\) diffuse, and (c\) specular reflection components](figures/example.jpg)

The primary objective of this toolbox is to serve as an aid for ongoing research and development of SIHR methods. Being written in such a high level language that is MATLAB/GNU Octave allows easier understanding of inner workings of these methods. To the best of our knowledge, the resources available to further the understanding of this specific problem are relatively scarce.

Hence, we have started ``SIHR`` in order to implement and gather several different methods from technical literature - starting from the most performing ones, since the abovementioned systems operate on a limited computing budget and need timely processing. Other methods of interest can be found in recent survey [@Artusi2011; @Khan2017].

Usage is rather straightforward as the focus of these methods is to work with only a single linear RGB image i.e. a *M*×*N*×3 matrix. For uniformity, we ask the image to be double-valued. In ``SIHR``, calls are simply ``I_d = AuthorYEAR(I);``, in which ``I`` is the original image and ``I_d`` is the estimate diffuse component calculated by the ``AuthorYEAR`` method. We refer to the ``SIHR`` documentation for the latest list of methods available. The specular component is ``I_s = I - I_d;``.

Figure 1 presents an actual result of a method from technical literature which was implemented in ``SIHR``.

``SIHR`` aims to be a continuous project and welcomes community contributions. The source code for ``SIHR`` is being archived by Zenodo since its pre-release version [@Ramos2019].

# References