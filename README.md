InterIMAGE Docker
=================

##Description

This Dockerfile is intended to install InterIMAGE and libraries it is based on.
InterIMAGE is an image interpretation software developed by [INPE](http://www.inpe.br),
the brazilian National Institute for Space Research.
See:
  http://tolomeofp7.unipv.it/SoftwareTools/InterIMAGE
  http://www.lvc.ele.puc-rio.br/projects/interimage

This Dockerfile fetches and compiles TerraLib, TerraAIDA and InterIMAGE.

####TerraLib is a GIS library
Website: http://www.terralib.org
Documentation: http://www.terralib.org/html/v410/index.html

####TerraAIDA provides image processing operators
Documentation:
  http://wiki.dpi.inpe.br/doku.php?id=interimage:operators_documentation
  http://wiki.dpi.inpe.br/doku.php?id=interimage:creating_operators

###Building the docker image

```
$ make build
```

###Running the created image

```
$ make run
```
