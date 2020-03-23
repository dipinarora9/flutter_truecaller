package dipinarora9.flutter_truecaller

import android.app.Activity
import android.util.Log
import androidx.annotation.NonNull
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
import java.util.*


/** FlutterTruecallerPlugin */
public class FlutterTruecallerPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {
    private var channel: MethodChannel? = null
    private var activity: Activity? = null
    private var initialized: Boolean = false

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "fluttertruecaller")
    }

    constructor()
    constructor(activity: Activity) {
        this.activity = activity
    }

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
                try {
                    if (!initialized) {
                        val trueScope = TruecallerSdkScope.Builder(this.activity!!.applicationContext, sdkCallback)
                                .consentMode(call.argument<Int>("consentMode")!!)
                                .consentTitleOption(call.argument<Int>("consentTitleOptions")!!)
                                .footerType(call.argument<Int>("footerType")!!)
                                .sdkOptions(call.argument<Int>("sdkOptions")!!)
                                .build()
                        TruecallerSDK.init(trueScope)
                        initialized = true
                        result.success("Truecaller SDK initialized")
                    } else result.success("Truecaller SDK already initialized")
                } catch (e: Exception) {
                    result.error("FAILED", e.message, null)
                }
            }
            "setLocale" -> {
                try {
                    if (initialized) {
                        val locale = Locale(call.arguments.toString())
                        TruecallerSDK.getInstance().setLocale(locale)
                        result.success("Locale set to ${call.arguments}")
                    } else result.success("Truecaller SDK not initialized")
                } catch (e: Exception) {
                    result.error("FAILED", e.message, null)
                }
            }
            "isUsable" -> {
                try {
                    if (initialized) {
                        val usable: Boolean = TruecallerSDK.getInstance().isUsable
                        result.success(usable)
                    } else
                        result.error("ERROR", "Truecaller SDK not initialized", false)
                } catch (e: Exception) {
                    result.error("FAILED", e.message, null)
                }
            }
            "getProfile" -> {
                try {
                    if (initialized) {
                        TruecallerSDK.getInstance().getUserProfile((this.activity as FragmentActivity?)!!)
                        result.success("")
                    } else
                        result.error("ERROR", "Truecaller SDK not initialized", false)
                } catch (e: Exception) {
                    result.error("FAILED", e.message, null)
                }
            }
            "phone" -> {
                try {
                    if (initialized) {
                        TruecallerSDK.getInstance().requestVerification("IN", call
                                .arguments.toString(), getCallBack(result), (activity as FragmentActivity?)!!)
                    } else
                        result.error("ERROR", "Truecaller SDK not initialized", false)
                } catch (e: Exception) {
                    result.error("FAILED", e.message, null)
                }
            }
        }
    }

    private val sdkCallback: ITrueCallback = object : ITrueCallback {
        override fun onSuccessProfileShared(trueProfile: TrueProfile) {
            // This method is invoked when either the truecaller app is installed on the device and the user gives his
            // consent to share his truecaller profile OR when the user has already been verified before on the same
            // device using the same number and hence does not need OTP to verify himself again.
            channel?.invokeMethod("profile", trueProfileToJson(trueProfile, "User verified without OTP").toString())
            channel?.invokeMethod("verificationRequired", false)
        }

        override fun onFailureProfileShared(trueError: TrueError) {
            // This method is invoked when some error occurs or if an invalid request for verification is made
            channel?.invokeMethod("callback", trueError.errorType.toString())
            channel?.invokeMethod("verificationRequired", false)
            Log.d("truecaller-testing", "onFailureProfileShared: " + trueError.errorType)
        }

        override fun onVerificationRequired() {
            // This method is invoked when truecaller app is not present on the device or if the user wants to
            // continue with a different number and hence, missed call verification is required to complete the flow
            // You can initiate the missed call verification flow from within this callback method by using :
            Log.d("truecaller-testing", "Please call manual verification method")
            channel!!.invokeMethod("verificationRequired", true)
            channel!!.invokeMethod("callback", "Please call manual verification method")
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
                        channel?.invokeMethod("callback", "User verified")
                        channel?.invokeMethod("profile", trueProfileToJson(profile!!, "").toString())
                    }
                    VerificationCallback.TYPE_PROFILE_VERIFIED_BEFORE -> {
                        channel?.invokeMethod("callback", "User already verified")
                        channel?.invokeMethod("profile", trueProfileToJson(profile!!, "").toString())
                    }
                }
            }

            override fun onRequestFailure(requestCode: Int, e: TrueException) {
                channel?.invokeMethod("callback", "${e.exceptionType} ${e.exceptionMessage}")
            }
        }
    }

    fun trueProfileToJson(profile: TrueProfile, verificationMode: String): JSONObject {
        val item = JSONObject()
        item.put("firstName", profile.firstName)
        item.put("lastName", profile.lastName)
        item.put("phoneNumber", profile.phoneNumber)
        item.put("gender", profile.gender)
        item.put("street", profile.street)
        item.put("city", profile.city)
        item.put("zipcode", profile.zipcode)
        item.put("countryCode", profile.countryCode)
        item.put("facebookId", profile.facebookId)
        item.put("twitterId", profile.twitterId)
        item.put("email", profile.email)
        item.put("url", profile.url)
        item.put("avatarUrl", profile.avatarUrl)
        item.put("isTrueName", profile.isTrueName)
        item.put("isAmbassador", profile.isAmbassador)
        item.put("companyName", profile.companyName)
        item.put("jobTitle", profile.jobTitle)
        item.put("payload", profile.payload)
        item.put("signature", profile.signature)
        item.put("signatureAlgorithm", profile.signatureAlgorithm)
        item.put("requestNonce", profile.requestNonce)
        item.put("isSimChanged", profile.isSimChanged)
        if (profile.verificationMode != null)
            item.put("verificationMode", profile.verificationMode)
        else
            item.put("verificationMode", verificationMode)
        item.put("verificationTimestamp", profile.verificationTimestamp)
        item.put("userLocale", profile.userLocale)
        item.put("accessToken", profile.accessToken)
        return item
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
