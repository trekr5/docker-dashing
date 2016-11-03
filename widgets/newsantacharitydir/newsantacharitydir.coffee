class Dashing.Newsantacharitydir extends Dashing.Widget

 ready: ->
    @get('donationcount')
    @get('donationamount')
    @get('totalamount')
    @get('giftaidamount')

 @accessor 'donationcount', Dashing.AnimatedValue
 @accessor 'donationamount', Dashing.AnimatedValue
 @accessor 'totalamount', Dashing.AnimatedValue
 @accessor 'giftaidamount', Dashing.AnimatedValue