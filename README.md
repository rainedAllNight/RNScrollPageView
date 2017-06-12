# RNScrollPageView
## a slideable page menu / 可滑动的分页菜单

![效果图1](https://github.com/rainedAllNight/RNScrollPageView/blob/master/RNImageViewPlayerCustom1.gif) ![效果图2](https://github.com/rainedAllNight/RNScrollPageView/blob/master/RNImageViewPlayerCustom2.gif)

# How to use

### Optional Property

**selectedIndex：** 默认选中的index, 默认为0(第一个)

**pageItemWidth：** 每个titleItem的宽度，如果不设置默认根据标题字数来适应

**pageItemHeight：** titleItem的高度，默认为40.0

**isHideSubLine：** 是否隐藏跟随滑动的subLineView，默认为false

**subLineHeigh：** subLineView的高度，默认为2.0

**subLineWidth：** subLineView的高度，如果不设置，默认等于pageItemWidth

**itemTitleMargin：** 两个titleItem之间的间距，默认为20.0

**subLineViewColor：** subLineView的颜色，默认为red红色

**titleColorNormal：** 标题正常状态下的颜色，默认为black黑色

**titleColorNormal：** 标题选中状态下的颜色，默认为red红色

**titleFontSizeNormal：** 标题正常状态下的字体大小，默认为system-14

**titleFontSizeSelected：** 标题选中下的字体大小，默认为system-16，如果isZoomTitle为true此值则不生效

**isZoomTitle：** 滑动时是否缩放标题，默认为true

**maxItemScale：** 缩放的最大比例，默认为1.2倍

**splitLineView：** 分割线

**splitLineViewHeight：** 分割线的高度

#### 或者你也可以在StoryBoard/Xib对这些属性进行设置

![image](https://github.com/rainedAllNight/RNScrollPageView/blob/master/3EB82318-82A6-4FE3-938C-B45B9A4B057B.png)

### Required Property

**viewControllers：** 控制器数组，或者可通过**conifg**方法传入

**titles：** 标题数组，或者可通过**config**方法传入

### Required Function 

**配置数据源**

` open func config(with viewControllers: [UIViewController], titles: [String]) `

 ### Delegate
 
**已经显示某个viewController时调用**

` @objc optional func scrollPageView(_ scrollPageView: RNScrollPageView, didShow viewController: UIViewController, at index: Int) `



