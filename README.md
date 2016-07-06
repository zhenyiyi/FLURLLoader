# FLURLLoader

// 警告：不要使用这些代码。


	dispatch_async(backgroundQueue, ^{
	
  		 NSData* contents = [NSData dataWithContentsOfURL:url]
   		 
   		 dispatch_async(dispatch_get_main_queue(), ^{
      	  // 处理取到的日期
   		});
	});
	
	

	乍看起来没什么问题，但是这段代码却有致命缺陷。你没有办法去取消这个同步的网络请求。它将阻塞住线程直到它完成。如果请求一直没结果，那就只能干等到超时（比如 dataWithContentsOfURL: 的超时时间是 30 秒）。

	如果队列是串行执行的话，它将一直被阻塞住。假如队列是并行执行的话，GCD 需要重开一个线程来补凑你阻塞住的线程。两种结果都不太妙，所以最好还是不要阻塞线程。

	要解决上面的困境，我们可以使用 NSURLConnection 的异步方法，并且把所有操作转化为 operation 来执行。通过这种方法，我们可以从操作队列的强大功能和便利中获益良多：我们能轻易地控制并发操作的数量，添加依赖，以及取消操作。

	然而，在这里还有一些事情值得注意： NSURLConnection 是通过 run loop 来发送事件的。因为时间发送不会花多少时间，因此最简单的是就只使用 main run loop 来做这个。然后，我们就可以用后台线程来处理输入的数据了。