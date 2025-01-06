extends Node2D

var _rewarded_ad : RewardedAd

func _ready() -> void:
	#The initializate needs to be done only once, ideally at app launch.
	MobileAds.initialize()
	_on_load_pressed()
	show_ad()
func _on_load_pressed():
	print("loading ads")
	#free memory
	if _rewarded_ad:
		#always call this method on all AdFormats to free memory on Android/iOS
		_rewarded_ad.destroy()
		_rewarded_ad = null

	var unit_id : String
	if OS.get_name() == "Android":
		unit_id = "ca-app-pub-3940256099942544/5224354917"
	elif OS.get_name() == "iOS":
		unit_id = "ca-app-pub-3940256099942544/1712485313"

	var rewarded_ad_load_callback := RewardedAdLoadCallback.new()
	rewarded_ad_load_callback.on_ad_failed_to_load = func(adError : LoadAdError) -> void:
		print(adError.message)

	rewarded_ad_load_callback.on_ad_loaded = func(rewarded_ad : RewardedAd) -> void:
		print("rewarded ad loaded" + str(rewarded_ad._uid))
		_rewarded_ad = rewarded_ad
		show_ad()

	RewardedAdLoader.new().load(unit_id, AdRequest.new(), rewarded_ad_load_callback)

func show_ad(): 
	print("showing ad")
	var on_user_earned_reward_listener = OnUserEarnedRewardListener.new()
	on_user_earned_reward_listener.on_user_earned_reward = func(rewarded_item : RewardedItem):
		print("on_user_earned_reward, rewarded_item: rewarded", rewarded_item.amount, rewarded_item.type)

	if _rewarded_ad:
		_rewarded_ad.show(on_user_earned_reward_listener)
