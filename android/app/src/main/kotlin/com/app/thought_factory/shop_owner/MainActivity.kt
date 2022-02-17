package com.app.thought_factory.shop_owner

//import io.flutter.embedding.android.FlutterActivity
import android.app.Activity
import android.content.Intent
import android.widget.Toast
import com.app.thought_factory.shop_owner.remote.ApiInterface
import com.app.thought_factory.shop_owner.request_response.request_payment.Authorization
import com.app.thought_factory.shop_owner.request_response.request_payment.DetailsRequest
import com.app.thought_factory.shop_owner.request_response.request_payment.Registration
import com.app.thought_factory.shop_owner.request_response.request_payment.RegistrationRequest
import com.app.thought_factory.shop_owner.request_response.response_payment.PaymentRegistrationResponse
import com.shatech.customerdetailapp.response.DetailsResponse
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import retrofit2.Call
import retrofit2.Callback
import retrofit2.Response
import retrofit2.Retrofit
import retrofit2.converter.gson.GsonConverterFactory
import java.util.*
import kotlin.collections.HashMap


class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.startActivity/testChannel"
    val LAUNCH_SECOND_ACTIVITY: Int = 1


    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

    }
}

