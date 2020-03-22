package dipinarora9.flutter_truecaller

import android.app.Activity
import android.util.Log
import androidx.annotation.NonNull;
import androidx.annotation.Nullable
import androidx.fragment.app.FragmentActivity
import com.truecaller.android.sdk.*
import com.truecaller.android.sdk.clients.VerificationCallback
import com.truecaller.android.sdk.clients.VerificationDataBundle
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry
import org.json.JSONObject

/** FlutterTruecallerPlugin */
public class FlutterTruecallerPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {
    private var channel: MethodChannel? = null
    private var activity: Activity? = null

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "fluttertruecaller")
    }

    constructor()
    constructor(activity: Activity) {
        this.activity = activity
    }

    // This static function is optional and equivalent to onAttachedToEngine. It supports the old
    // pre-Flutter-1.12 Android projects. You are encouraged to continue supporting
    // plugin registration via this function while apps migrate to use the new Android APIs
    // post-flutter-1.12 via https://flutter.dev/go/android-project-migration.
    //
    // It is encouraged to share logic between onAttachedToEngine and registerWith to keep
    // them functionally equivalent. Only one of onAttachedToEngine or registerWith will be called
    // depending on the user's project. onAttachedToEngine or registerWith must both be defined
    // in the same class.
    companion object {
        @JvmStatic
        fun registerWith(registrar: PluginRegistry.Registrar) {
            val channel = MethodChannel(registrar.messenger(), "fluttertruecaller")
            channel.setMethodCallHandler(FlutterTruecallerPlugin(registrar.activity()))
        }
    }


    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            "initialize" -> {
                val trueScope = TruecallerSdkScope.Builder(this.activity!!.applicationContext, sdkCallback)
                        .consentMode(call.argument<Int>("consentMode")!!)
                        .consentTitleOption(call.argument<Int>("consentTitleOptions")!!)
                        .footerType(call.argument<Int>("footerType")!!)
                        .sdkOptions(call.argument<Int>("sdkOptions")!!)
                        .build()

                TruecallerSDK.init(trueScope)
                result.success("Truecaller sdk initialized")
            }
            "isUsable" -> {
                val usable: Boolean = TruecallerSDK.getInstance().isUsable
                result.success("Android $usable")
            }
            "getProfile" -> {
                TruecallerSDK.getInstance().getUserProfile((this.activity as FragmentActivity?)!!)
                result.success("")
            }
            "phone" -> {
                TruecallerSDK.getInstance().requestVerification("IN", call
                        .arguments.toString(), getCallBack(result), (activity as FragmentActivity?)!!)
            }
        }
    }

    private val sdkCallback: ITrueCallback = object : ITrueCallback {
        override fun onSuccessProfileShared(trueProfile: TrueProfile) {

            // This method is invoked when either the truecaller app is installed on the device and the user gives his
            // consent to share his truecaller profile OR when the user has already been verified before on the same
            // device using the same number and hence does not need OTP to verify himself again.
            val item = JSONObject()
            item.put("profile", trueProfile.toString())
            item.put("message", "User verified without OTP")
            channel?.invokeMethod("callback", item.toString())
        }

        override fun onFailureProfileShared(trueError: TrueError) {
            // This method is invoked when some error occurs or if an invalid request for verification is made
            channel!!.invokeMethod("callback", "onFailureProfileShared: " + trueError.errorType)
        }

        override fun onVerificationRequired() {
            // This method is invoked when truecaller app is not present on the device or if the user wants to
            // continue with a different number and hence, missed call verification is required to complete the flow
            // You can initiate the missed call verification flow from within this callback method by using :
//            channel?.setMethodCallHandler { call, result ->
//
//            }
            channel!!.invokeMethod("callback", "please call verify method")
        }
    }

    private fun getCallBack(result: Result? = null, profile: TrueProfile? = null): VerificationCallback {
        return object : VerificationCallback {
            override fun onRequestSuccess(requestCode: Int, @Nullable extras: VerificationDataBundle?) {

                when (requestCode) {
                    VerificationCallback.TYPE_MISSED_CALL_INITIATED -> {
                        Log.d("truecaller-testing", "drop call is successfully initiated")
                        result?.success(false)
                    }
                    VerificationCallback.TYPE_MISSED_CALL_RECEIVED -> {
                        Log.d("truecaller-testing", "drop call is successfully detected")
                        channel?.setMethodCallHandler { call, result ->
                            if (call.method == "verifyMissCall") {
                                val userProfile = TrueProfile.Builder(call
                                        .argument("firstName")!!, call
                                        .argument("lastName")!!).build()
                                verifyMissedCall(userProfile)
                            }
                        }
//                    channel?.invokeMethod("callback", "drop call is successfully detected")
                    }
                    VerificationCallback.TYPE_OTP_INITIATED -> {
                        Log.d("truecaller-testing", "drop call is successfully initiated")
                        result?.success(true)
                    }
                    VerificationCallback.TYPE_OTP_RECEIVED -> {
                        Log.d("truecaller-testing", "OTP is successfully detected")
                        channel?.setMethodCallHandler { call, result ->
                            if (call.method == "verifyOTP") {
                                val userProfile = TrueProfile.Builder(call
                                        .argument("firstName")!!, call
                                        .argument("lastName")!!).build()
                                verifyOTP(userProfile, call
                                        .argument("otp")!!)
                            }
                        }
//                    channel?.invokeMethod("callback", "OTP is successfully detected")
                    }
                    VerificationCallback.TYPE_VERIFICATION_COMPLETE -> {
                        val item = JSONObject()
                        item.put("profile", profile.toString())
                        item.put("message", "User verified")
                        channel?.invokeMethod("callback", item.toString())
                    }
                    VerificationCallback.TYPE_PROFILE_VERIFIED_BEFORE -> {
                        val item = JSONObject()
                        item.put("profile", profile.toString())
                        item.put("message", "User is already verified")
                        channel?.invokeMethod("callback", item.toString())
                    }
                }
            }

            override fun onRequestFailure(requestCode: Int, e: TrueException) {
                channel?.invokeMethod("callback", "${e.exceptionType} ${e.exceptionMessage}")
            }
        }
    }

    fun verifyOTP(profile: TrueProfile, OTP: String) {
        TruecallerSDK.getInstance().verifyOtp(profile, OTP, getCallBack(profile = profile))
    }

    fun verifyMissedCall(profile: TrueProfile) {
        TruecallerSDK.getInstance().verifyMissedCall(profile, getCallBack(profile = profile))
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
        binding.addActivityResultListener { _, i2, intent -> TruecallerSDK.getInstance().onActivityResultObtained((this.activity as FragmentActivity?)!!, i2, intent) }
        channel?.setMethodCallHandler(this)
    }

    override fun onDetachedFromActivityForConfigChanges() {

        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
        binding.addActivityResultListener { _, i2, intent -> TruecallerSDK.getInstance().onActivityResultObtained((this.activity as FragmentActivity?)!!, i2, intent) }
    }


    override fun onDetachedFromActivity() {
        activity = null
        channel?.setMethodCallHandler(null)
    }
}
