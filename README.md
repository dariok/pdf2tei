# PDF2TEI

basic conversion from PDF to TEI trying to guess the structure of a text. *Postprocessing required!*

## Usage

There are three basic ways to use this package. If you use oXygen, you can use the transformation scenario defined in
the oXygen project (see below). Alternatively, you can use the ANT task defined in build.xml (see further below) or as a
last option, do it manually.

### oXygen transformation scenario
A general scenario is defined in pdf2tei.xpr. You may need to adjust the parameters, **especially 'saxon'** which
contains the path to a JAR of the Saxon XSLT processor (e.g. saxon-he-10.5.jar, as is used in the example).

You can use
a jar from the oXygen directories but **not** one of the `oxygen-patched-saxon-9.jar` (or similar). Alternatively, you
can get the latest version from Saxonica ([https://www.saxonica.com/download/download_page.xml] for a complete selection
of the available editions) or the current version of the _Home Edition_ directly from sourceforge
([https://sourceforge.net/projects/saxon/files/Saxon-HE/10/Java/] for the current line of Saxon 10).

### Using command line ANT
With ant available on your path, you can directly call ant to run the predefined workflow in build.xml. You need to set
the parameters to the values for you situation:
- `name`: the base name to be used for the resulting TEI file and the directory below outDir
- `outDir`: path to the directory where the output is to be stored
- `pdf`: path to the PDF file to be processed
- `saxon`: path to a Saxon .jar (see the remarks in the previous section)

Example:
```
ant -Dname=pdftei -DoutDir=../output -Dpdf=../incoming/pdf-to-tei.pdf -Dsaxon=saxon-he-10.5.jar
```

### General workflow
1. use `pdftohtml -xml file.pdf` to create a basic XML
1. apply `pt1.xsl` to `pt4.xsl` sequentially

## Limitations
While these scripts try their best to guess a structure – headings, paragraphs – from the PDF, there are major
limitations to this approach. Hence, the output is not valid TEI but must be postprocessed.
We cannot, for instance, determine for certain whether a smaller passage is a footnote or a quotation without knowledge
of the contents. Also, we can only assume that a page has a maximum of one line of heading and footer each. Pages with
more than that will result in a wrong structure and possibly a column break.

To facilitate the postprocessing, values that were calculated during transformation were retained in the result. This
means that there are the dimensional attributes @left, @top, @size, @bottom, and @right present for every line, and
@height, @width, and @l (for the most frequently used @left of all lines) on pb.
Additionally, all tei:l are comprised of one or more tei:hi with layout information (most importantly @rendition but
also dimensional attributes).
