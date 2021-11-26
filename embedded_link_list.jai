// v92
#import "Basic";

linkS :: struct {
    next : *#this;
    prev : *#this;
}

data_linkS :: struct ($DATA : Type) {
    using link : linkS;
    using data : DATA;
}

link_reset :: (link : *linkS)
{
    link.next = link;
    link.prev = link;
}

link_next :: (link : *$T/linkS) -> *$T #expand {
    return cast (*T)link.next;
}

link_prev :: (link : *$T/linkS) -> *$T #expand {
    return cast (*T)link.prev;
}

link_add :: (link : *linkS, add : *linkS)
{
    link_left_middle_right :: (left : *linkS, middle : *linkS, right : *linkS) #expand
    {
        left.next = middle;
        middle.prev = left;
        middle.next = right;
        right.prev = middle;
    }
    link_left_middle_right(link, add, link.next);
}

link_remove :: (link : *linkS)
{
    link_left_middle_right_delete :: (left : *linkS, middle : *linkS, right : *linkS) #expand
    {
        left.next = right;
        right.prev = left;
        middle.prev = middle;
        middle.next = middle;
    }
    link_left_middle_right_delete(link.prev, link, link.next);
}

unitS :: struct {
    id : s64;
    health : int;
    armor : int;
    speed : float;
    food : float;
    goat_count : int;
}
itemS :: struct {
    id : s64;
    dice_count : int;
    dice_side : int;
    hit_bonus : int;
    dam_bonus : int;
    enchantment : int;
}

main :: ()
{
    test_link :: ($T : Type) #expand {
        linkT :: data_linkS(T);
        head : linkT;
        link_reset(*head);

        add :: (id : s64) -> *linkT #expand {
            ptr := New(linkT);
            ptr.id = id;
            link_add(*head, ptr);
            return ptr;
        }

        add(1);
        add(2);
        third := add(3);
        add(4);
        link_remove(third);

        iter := link_next(*head);
        while iter != *head {
            print("%\n", iter.data);
            iter = link_next(iter);
        }
    }
    test_link(unitS);
    test_link(itemS);
}
