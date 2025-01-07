extends Node2D

@onready var _play_billing: PlayBilling = $PlayBilling

func _ready():
	_play_billing.start_connection()
	_play_billing.query_product_details(["id"], PlayBilling.ProductType.INAPP)

	_play_billing.purchase("product_id") # purchase
# connect
func _on_play_billing_connected() -> void:
	_play_billing.query_product_details(["product_ids"], PlayBilling.ProductType.INAPP)
func _on_play_billing_connect_error(error_code: PlayBilling.BillingResponseCode, debug_message: String) -> void:
	print(error_code, debug_message)
	
# query availabe products 
func _on_play_billing_product_details_query_completed(product_detail_list: Array[ProductDetail]) -> void:
	print(product_detail_list)

func _on_play_billing_product_details_query_error(error_code: PlayBilling.BillingResponseCode, debug_message: String, product_id_list: Array[String]) -> void:
	print(error_code, debug_message, product_id_list)

# purchase made by users 
# Save purchase for future verification.
func _on_play_billing_purchases_updated(purchases: Array[Purchase]) -> void:
	for purchase in purchases:
		if purchase.purchase_state == Purchase.PurchaseState.PURCHASED:
			if "product_id" in purchase.product_ids and !purchase.is_acknowledged:
				# acknowledge for 1 time product buy
				_play_billing.acknowledge_purchase(purchase.purchase_token)
				
				# consume for multiple buy (for consumables like coins)
				# this call acknowledge automatically under the hood
				#_play_billing.consume_purchase(purchase.purchase_token)



func _on_play_billing_purchases_updated_error(error_code: PlayBilling.BillingResponseCode, debug_message: String) -> void:
	print(error_code, debug_message)
	
# purchase request replied by Google
func _on_play_billing_purchase_acknowledged(purchase_token: String) -> void:
	# _purchase is the saved list of purchases.
	var _purchases = [] # this could be understood as purchase request made from client
	for purchase: Purchase in _purchases:
		if purchase_token == purchase.purchase_token:
			# when a request is replied, it means it's accepted 
			if "product_id" in purchase.product_ids:
				# Award item to user.
				pass


func _on_play_billing_purchase_acknowledgement_error(error_code: PlayBilling.BillingResponseCode, debug_message: String, purchase_token: String) -> void:
	print(error_code, debug_message, purchase_token)
