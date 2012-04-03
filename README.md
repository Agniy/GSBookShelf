An iBooks style book shelf

Attention:

1. This code should be compiled with ARC turned on;

---

Features:

1. drag & drop
2. scroll up/down while draging
3. add & remove animation
4. custom header (add a search bar or anything you want)
5. **[NEW 12.04.03]** The demo supports oritation changing now, but I'm too lazy to make a new cell image. Just reset the number of books in each cell.(3 when portrait, 4 when landscape).


---

How TO:

1. Just take a look at the demo.
2. bookView and shelfCell are just UIViews. So you can cutomize them almost whatever you want. But the frame of each view is fixed, if you want to have different size of bookView, you can try adding your content on a transparent UIView.
3. To enable reusing for bookViews and cells, add the <GSBookView> / <GSBookShelfCell> protocols. (You'd better do this, perfromance will be a lot better).
4. To support oritation change, you should call the reload method and return different values (if necessary) in the delegate method with different orientation.

--

TODO:

1. **[Done]** ~~does not support orientation change now, it's fixed Portrait or landscape (doesn't have a convenient method to reload the parameters which was set in the init method.)~~ 

2. **[Done]** ~~the init method need too many parameters now. I will move all of them to GSBookShelfViewDataSource protocol methods, and this will help a lot when orientation changes, but maybe there'll be too many protocol methods.~~

3. **[NEW 12.04.03]** Maybe there should be some animation for cell when the orientation change.

Demo:(Be Patient, some gifs' size > 1M)

![image](https://github.com/ultragtx/ultragtx.github.com/blob/master/images/Move_s.gif?raw=true)
![image](https://github.com/ultragtx/ultragtx.github.com/blob/master/images/Add_s.gif?raw=true)
![image](https://github.com/ultragtx/ultragtx.github.com/blob/master/images/Delete_s.gif?raw=true)