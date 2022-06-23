include "stdlib/std.sf";

abstract record listBucket<T>;

final record emptyBucket<T> extends listBucket<T>;

final record elemListBucket<T> extends listBucket<T> {
	T elem;
	listBucket<T> next = new emptyBucket<T>;
}

final record linkedList<T> {
	listBucket<T> head = new emptyBucket<T>;
	int count = 0;
}

global readonly auto pushFront = proc<T>(linkedList<T> l, T elem) {
	l.count = l.count + 1;
	return l.head = new elemListBucket<T> {
		elem = elem;
		next = l.head;
	};
};

global readonly auto popFront = proc<T>(linkedList<T> l) return fallible<T> {
	if(l.head is emptyBucket<any>)
		return new invalidOperation<T> {
			msg = "Cannot pop from empty list.";
		};
	else {
		l.count = l.count - 1;
		auto elemHead = dynamic_cast<elemListBucket<T>>(l.head);
		l.head = elemHead.next;
		return new success<T> {
			result = elemHead.elem;
		};
	}
};

global readonly auto linkedListForAll = proc<T>(linkedList<T> l, proc<nothing, T> todo) {
	for(listBucket<T> current = l.head; current is elemListBucket<T>; current = dynamic_cast<elemListBucket<T>>(current).next)
		todo(dynamic_cast<elemListBucket<T>>(current).elem);
};

global readonly auto linkedListToArray = proc<T>(linkedList<T> l) {
	array<T> buffer = new T[l.count];
	listBucket<T> current = l.head;
	for(int i = 0; i < #buffer; i++) {
		auto elemBucket = dynamic_cast<elemListBucket<T>>(current);
		buffer[i] = elemBucket.elem;
		current = elemBucket.next;
	}
	return buffer;
};