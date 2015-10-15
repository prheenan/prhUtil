# import utilities for error repoorting etc
import GenUtilities as util
# use matplotlib for plotting
#http://matplotlib.org/faq/usage_faq.html#what-is-a-backend
import matplotlib.pyplot  as plt
# import numpy for array stuff
import numpy as np
# for color cycling
from itertools import cycle
import sys
import os 

g_font_label = 20
g_font_title = 22
g_font_legend = 18
g_tick_thickness = 2
g_tick_length = 12

# based on :http://stackoverflow.com/questions/18699027/write-an-upright-mu-in-matplotlib
#plt.rc('font', **{'sans-serif' : 'Arial', 'family' : 'sans-serif'})
# following line sets the mathtext to whatever is our font
plt.rcParams['mathtext.fontset'] = 'custom'
plt.rcParams['font.sans-serif'] = 'Georgia'
plt.rcParams['font.family'] = 'sans-serif'
# to get a list of all fonts:

def addColorbar(fig,cmap,nPoints,colorRange=None,left=0.80,bottom=0.15,
                width=0.03,height=0.7,tickLabels=None,
                orientation='vertical',tickOffsets=None,
                ticklocation='right',**kwargs):
    # XXX for now, assume the color bar is on the right; only need to 
    # adjust right
    fig.subplots_adjust(right=left-width)
        # add in a colorbar 
    cbar_axis = fig.add_axes([left,bottom,width,height])
    m = plt.cm.ScalarMappable(cmap=cmap)
    mArr = [0,1.]
    if (colorRange is not None):
        mArr = colorRange
    # figure out where to put the ticks
    # by default, just assume we space things linearly
    if (tickOffsets is None):
        # get an array going from the start of the array to the 
        # end uniformly
        mArrOffsets = np.linspace(mArr[0],mArr[-1],len(tickLabels),
                                  endpoint=True)
        tickOffsets = mArrOffsets
    m.set_array(mArr)
    cbar = fig.colorbar(cax= cbar_axis,mappable=m,orientation=orientation,
                        ticklocation=ticklocation,ticks=tickOffsets)
    mAx = cbar.ax
    # add the labels, if we need them.
    if (tickLabels is not None):
        if (orientation == 'vertical'):
            cbar.ax.set_yticklabels(tickLabels)
        else:
            cbar.ax.set_xticklabels(tickLabels)
    tickAxisFont(ax=mAx)


def errorbar(x,y,yerr,label,fmt=None,alpha=0.1,ecolor='r',markersize=3.0,
             *args,**kwargs):
    # plot the data, a 'haze' around it, and dotted lines 
    if (fmt is None):
        fmt = "go"
    plt.fill_between(x, y - yerr,y + yerr, alpha=alpha,color=ecolor)
    plt.plot(x, y,fmt,label=label,markersize=markersize,*args,**kwargs)
    plt.plot(x, y+yerr,'b--')
    plt.plot(x, y-yerr,'b--')
    
def legend(fontsize=g_font_legend,loc=None,frameon=False,**kwargs):
    if (loc is None):
        loc = 'best'
    plt.legend(fontsize=fontsize,loc=loc,frameon=frameon,**kwargs)


def intLim(vals,xAxis=True,factor=0.5):
    # intelligently set the limits
    uni = np.unique(vals)
    maxV = vals[-1]
    minV = vals[0]
    # fudge factor is a factor of the minimum change
    if (uni.size == 1):
        # just a single point
        fudge = max(1,uni[0]*0.5)
    else:
        fudge = np.min(np.diff(uni))*0.5
    # set the limits
    if (xAxis):
        plt.gca().set_xlim(minV-fudge,maxV+fudge)
    else:
        plt.gca().set_ylim(minV-fudge,maxV+fudge)

def xlabel(lab,fontsize=g_font_label,**kwargs):
    plt.xlabel(lab,fontsize=fontsize,**kwargs)

def ylabel(lab,fontsize=g_font_label,**kwargs):
    plt.ylabel(lab,fontsize=fontsize,**kwargs)

def title(lab,fontsize=g_font_title,**kwargs):
    plt.title(lab,fontsize=fontsize,**kwargs)

def lazyLabel(xlab,ylab,titLab,yrotation=90,frameon=False,loc='best',**kwargs):
    xlabel(xlab,**kwargs)
    ylabel(ylab,rotation=yrotation,**kwargs)
    title(titLab,**kwargs)
    tickAxisFont(**kwargs)
    legend(frameon=frameon,loc=loc,**kwargs)

def tickAxisFont(fontsize=g_font_label,ax=None):
    plt.tick_params(axis='both', which='major', labelsize=fontsize)
    plt.tick_params(axis='both', which='minor', labelsize=fontsize)
    if (ax is None):
        ax = plt.gca()
    ax.xaxis.set_tick_params(width=g_tick_thickness,length=g_tick_length)
    ax.yaxis.set_tick_params(width=g_tick_thickness,length=g_tick_length)

def xTickLabels(xRange,labels,rotation='vertical',fontsize=g_font_label,
                **kwargs):
    tickLabels(xRange,labels,True,rotation=rotation,fontsize=fontsize,**kwargs)

def yTickLabels(xRange,labels,rotation='horizontal',fontsize=g_font_label,
                **kwargs):
    tickLabels(xRange,labels,False,rotation=rotation,fontsize=fontsize,**kwargs)

def tickLabels(xRange,labels,xAxis,**kwargs):
    ax = plt.gca()
    if (xAxis):
        ax.set_xticks(xRange)
        ax.set_xticklabels(labels,**kwargs)
    else:
        ax.set_yticks(xRange)
        ax.set_yticklabels(labels,**kwargs)


def cmap(num,cmap = plt.cm.gist_earth_r):
    return cmap(np.linspace(0, 1, num))

def useTex():
    # may need to install:
    # tlmgr install dvipng helvetic palatino mathpazo type1cm
    # http://stackoverflow.com/questions/14389892/ipython-notebook-plotting-with-latex
    from matplotlib import rc
    sys.path.append("/usr/texbin/")
    rc('font',**{'family':'sans-serif','sans-serif':['Helvetica']})
    rc('text', usetex=True)

def addColorBar(cax,ticks,labels,oritentation='vertical'):
    cbar = plt.colorbar(cax, ticks=ticks, orientation='vertical')
    # horizontal colorbar
    cbar.ax.set_yticklabels(labels,fontsize=g_font_label)

# add a second axis to ax.
def secondAxis(ax,label,limits,secondY =True,yColor="Black",scale=None):
    #copies the first axis (ax) and uses it to overlay an axis of limits
    axOpt = dict(fontsize=g_font_label)
    if (scale is None):
        if secondY:
            scale = ax.get_yscale() 
        else:
            scale = ax.get_xscale()
    if(secondY):
        ax2 = ax.twinx()
        ax2.set_yscale(scale, nonposy='clip')
        ax2.set_ylim(limits)
        # set the y axis to the appropriate label
        lab = ax2.set_ylabel(label,**axOpt)
        ticks = ax2.get_yticklabels()
    else:
        ax2 = ax.twiny()
        ax2.set_xscale(scale, nonposy='clip')
        ax2.set_xlim(limits)
        # set the x axis to the appropriate label
        lab = ax2.set_xlabel(label,**axOpt)
        ticks = ax2.get_xticklabels()
    [i.set_color(yColor) for i in ticks]
    lab.set_color(yColor)
    tickAxisFont()
    return ax2

def pm(stdOrMinMax,mean=None,fmt=".3g"):
    if (mean ==None):
        mean = np.mean(stdOrMinMax)
    arr = np.array(stdOrMinMax)
    if (len(arr) == 1):
        delta = arr[0]
    else:
        delta = np.mean(np.abs(arr-mean))
    return ("{:"+ fmt + "}+/-{:.2g}").format(mean,delta)

def savefig(figure,fileName,close=True,tight=True,**kwargs):
    # source : where to save the output iunder the output folder
    # filename: what to save the file as. automagically saved as high res pdf
    # override IO: if true, ignore any path infomation in the file name stuff.
    # close: if true, close the figure after saving.
    if (tight):
        plt.tight_layout(True)
    baseName = util.getFileFromPath(fileName)
    if ("." not in baseName):
        formatStr = ".svg"
        fullName = fileName + formatStr
    else:
        _,formatStr = os.path.splitext(fileName)
        fullName = fileName
    figure.savefig(fullName,format=formatStr[1:], 
                   dpi=figure.get_dpi(),**kwargs)
    if (close):
        plt.close(figure)

def figure(xSize=10,ySize=8,dpi=100):
    return  plt.figure(figsize=(xSize,ySize),dpi=dpi)

def getNStr(n,space = " "):
    return space + "n={:d}".format(n)

# legacy API. plan is now to mimic matplotlib 
def colorCyc(num,cmap = plt.cm.winter):
    cmap(num,cmap)
def pFigure(xSize=10,ySize=8,dpi=100):
    return figure(xSize,ySize,dpi)
def saveFigure(figure,fileName,close=True):
    savefig(figure,fileName,close)
