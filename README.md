# ThreadTesthnas
ios三种多线程技术：
1.nsthread
(1)使用nsthread对象建立一个线程非常方便
(2)但是！要使用nsthread管理多个线程非常困难，不推荐使用
(3)技巧！使用[nsthread currentthread]跟踪任务所在线程，适用于这三种技术
2.nsoperation/nsoperationqueue
(1)是使用gcd实现的一套objective-c的api
(2)是面向对象的线程技术
(3)提供了一些在gcd中不容易实现的特性，如：限制最大并发数量、操作之间的依赖关系
3.GCD —— grand central dispatch
(1)是基于c语言的底层api
(2)用block定义任务，使用起来非常灵活便捷
(3)提供了更多的控制能力以及操作队列中所不能使用的底层函数

下面重点了解GCD多线程
GCD原型：函数（队列，任务）== dispatch_sync(queue, ^{});

GCD中函数的概念：同步&异步：
函数：dispatch_sync，dispatch_async
函数作用：将任务添加到队列中
函数类型：决定是否有开启新线程的能力

同步：
同步执行：比如这里的dispatch_sync，这个函数会把一个block加入到指定的队列中，而且会一直等到执行完blcok，这个函数才返回。因此在block执行完之前，调用dispatch_sync方法的线程是阻塞的。
同步函数：不具备开启新线程的能力，只能在当前线程中执行任务

异步：
异步执行：一般使用dispatch_async，这个函数也会把一个block加入到指定的队列中，但是和同步执行不同的是，这个函数把block加入队列后不等block的执行就立刻返回了。
异步函数：具备开启线程的能力，但不一定开启新线程，比如：当前队列为主队列，异步函数也不会开启新的线程

经验总结：
通过同步函数添加任务到队列中，任务会立即执行
通过异步函数添加任务到队列中，任务不会立即执行


使用GCD多线程程序猿只需要做下列事情：
指定函数类型：是否具备开启新线程的能力（dispatch_sync还是dispatch_async）
指定队列类型：决定任务的执行方式（dispatch_queue_t）
确定要执行的任务（block），并通过函数（dispatch_sync还是dispatch_async）将任务添加到队列（dispatch_queue_t）中；任务的执行遵循队列的FIFO原则：先进先出，后进后出
剩下的事情就交给GCD来完成了

GCD中队列的概念：“串行&并发”
串行：
串行队列：比如这里的dispatch_get_main_queue。这个队列中所有任务，一定按照先来后到的顺序执行。不仅如此，还可以保证在执行某个任务时，在它前面进入队列的所有任务肯定执行完了。对于每一个不同的串行队列，系统会为这个队列建立唯一的线程来执行代码。

并发：
并发队列：比如使用dispatch_get_global_queue。这个队列中的任务也是按照先来后到的顺序开始执行，注意是开始，但是它们的执行结束时间是不确定的，取决于每个任务的耗时。对于n个并发队列，GCD不会创建对应的n个线程而是进行适当的优化


***************************************************************************************************************************************************************
进程&线程：
进程:正在进行中的程序应用被称为进程，负责程序运行的内存分配;每一个进程都有自己独立的虚拟内存空间
进程:一个正在运行的程序,叫一个进程    
多进程:多个程序正在运行,叫多进程    

线程:线程是进程中一个独立的执行路径(控制单元);一个进程中至少包含一条线程，即主线程
线程:一个程序或者说一个进程都会有一个或多个线程 如果只有一个 我们叫他主线程 主线程负责用户能看见的任务 例如添加控件 刷新页面,除了主线程以外都叫子线程, 线程之间是独立的没有任何联系,子线程一般负责用户不直接看到的任务 例如加载图片的过程 下载视频等。 线程要明确的:只要用户看得见的 或者 跟用户看得见有关的 都使用主线程 进行操作。 因为开启子线程操作的时候 是为了更好地用户体验 用户体验直接的表现为看到的或者点击的流畅性。 线程是耗费资源的，虽然可以多线程操作 可以提高用户体验 但是不建议 进行很多线程同时进行操作。

---------------------
作者：刘新林 
来源：CSDN 
原文：https://blog.csdn.net/Loving_iOS/article/details/48660703?utm_source=copy 
版权声明：本文为博主原创文章，转载请附上博文链接！

队列种类：
队列 dispatch_queue_t，队列名称在调试时辅助，无论什么队列和任务，线程的创建和回收不需要程序员操作，有队列负责。
串行队列：队列中的任务只会顺序执行(类似接力跑步)
dispatch_queue_t q = dispatch_queue_create(“....”, DISPATCH_QUEUE_SERIAL);

并行队列：队列中的任务通常会并发执行(类似赛跑)
dispatch_queue_t q = dispatch_queue_create("......", dispatch_queue_concurrent);

全局队列：是系统开发的，直接拿过来（get）用就可以；与并行队列类似，但调试时，无法确认操作所在队列
dispatch_queue_t q = dispatch_get_global_queue(dispatch_queue_priority_default, 0);
　　　　　　　　　　　　　　　　　　
主队列：每一个应用开发程序对应唯一一个主队列，直接get即可；在多线程开发中，使用主队列更新ui
dispatch_queue_t q = dispatch_get_main_queue();
　　　　　　　　　　　　　　　　　　
操作
dispatch_async 异步操作，会并发执行，无法确定任务的执行顺序；
dispatch_sync 同步操作，会依次顺序执行，能够决定任务的执行顺序；

1.串行队列同步：操作不会新建线程、操作顺序执行
2.串行队列异步：操作需要一个子线程，会新建线程、线程的创建和回收不需要程序员参与，操作顺序执行，“最安全的选择”
3.并行队列同步：操作不会新建线程、操作顺序执行
4.并行队列异步：操作会新建多个线程（对于n个并发队列，GCD不会创建对应的n个线程而是进行适当的优化）、操作无序执行；队列前如果有其他任务，会等待前面的任务完成之后再执行；场景：既不影响主线程，又不需要顺序执行的操作！
5.全局队列异步：操作会新建多个线程、操作无序执行，队列前如果有其他任务，会等待前面的任务完成之后再执行
6.全局队列同步：操作不会新建线程、操作顺序执行
7.主队列异步：操作都应该在主线程上顺序执行的，不存在异步的概念
8.主队列同步：如果把主线程中的操作看成一个大的block，那么除非主线程被用户杀掉，否则永远不会结束；主队列中添加的同步操作永远不会被执行，会死锁

1---- 队列和线程的区别：

队列：是管理线程的，相当于线程池,能管理线程什么时候执行。
队列分为串行队列和并行队列等
串行队列：队列中的线程按顺序执行（不会同时执行）
并行队列：队列中的线程会并发执行，可能会有一个疑问，队列不是先进先出吗，如果后面的任务执行完了，怎么出去的了。这里需要强调下，任务执行完毕了，不一定出队列。只有前面的任务执行完了，才会出队列。

2----- 主线程队列和gcd创建的队列也是有区别的。

主线程队列和gcd创建的队列是不同的。在gcd中创建的队列优先级没有主队列高，所以在gcd中的串行队列开启同步任务里面没有嵌套任务是不会阻塞主线程，只有一种可能导致死锁，就是串行队列里，嵌套开启任务，有可能会导致死锁。

主线程队列中不能开启同步，会阻塞主线程。只能开启异步任务，开启异步任务也不会开启新的线程，只是降低异步任务的优先级，让cpu空闲的时候才去调用。而同步任务，会抢占主线程的资源，会造成死锁。

3----- 线程：里面有非常多的任务（同步，异步）
同步与异步的区别：
同步任务优先级高，在线程中有执行顺序，不会开启新的线程。
异步任务优先级低，在线程中执行没有顺序，看cpu闲不闲。在主队列中不会开启新的线程，其他队列会开启新的线程。

4----主线程队列注意：
下面代码执行顺序
1111
2222
主队列异步 <nsthread: 0x8e12690>{name = (null), num = 1}
在主队列开启异步任务，不会开启新的线程而是依然在主线程中执行代码块中的代码。为什么不会阻塞线程？
> 主队列开启异步任务，虽然不会开启新的线程，但是他会把异步任务降低优先级，等闲着的时候，就会在主线程上执行异步任务。
在主队列开启同步任务，为什么会阻塞线程？

> 在主队列开启同步任务，因为主队列是串行队列，里面的线程是有顺序的，先执行完一个线程才执行下一个线程，而主队列始终就只有一个主线程，主线程是不会执行完毕的，因为他是无限循环的，除非关闭应用开发程序。因此在主线程开启一个同步任务，同步任务会想抢占执行的资源，而主线程任务一直在执行某些操作，不肯放手。两个的优先级都很高，最终导致死锁，阻塞线程了。
