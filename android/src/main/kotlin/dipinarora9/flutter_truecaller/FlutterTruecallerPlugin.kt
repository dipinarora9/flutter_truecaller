package dipinarora9.flutter_truecaller

import android.app.Activity
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
    private var mobile: String = ""
    private var getProfileCalled: Boolean = true

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "flutter_truecaller")
    }

    constructor()
    constructor(activity: Activity) {
        this.activity = activity
    }

    companion object {
        @JvmStatic
        fun registerWith(registrar: PluginRegistry.Registrar) {
            val channel = MethodChannel(registrar.messenger(), "flutter_truecaller")
            val plugin = FlutterTruecallerPlugin(registrar.activity())
            channel.setMethodCallHandler(plugin)
            registrar.addActivityResultListener { _, resultCode, intent -> if (plugin.initialized && plugin.getProfileCalled) TruecallerSDK.getInstance().onActivityResultObtained((registrar.activity() as FragmentActivity?)!!, resultCode, intent) else true }
        }
    }


    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            "initialize" -> {
                try {
                    if (!initialized) {
                        val trueScope = TruecallerSdkScope.Builder(this.activity!!.applicationContext, sdkCallback)
                                .consentMode(call.argument<Int>("consentMode")!!)
                                .buttonColor(call.argument<Int>("buttonColor")!!)
                                .buttonTextColor(call.argument<Int>("buttonTextColor")!!)
                                .loginTextPrefix(call.argument<Int>("loginTextPrefix")!!)
                                .loginTextSuffix(call.argument<Int>("loginTextSuffix")!!)
                                .ctaTextPrefix(call.argument<Int>("ctaTextPrefix")!!)
                                .buttonShapeOptions(call.argument<Int>("buttonShapeOptions")!!)
                                .privacyPolicyUrl(call.argument<String>("privacyPolicyUrl")!!)
                                .termsOfServiceUrl(call.argument<String>("termsOfServiceUrl")!!)
                                .footerType(call.argument<Int>("footerType")!!)
                                .consentTitleOption(call.argument<Int>("consentTitleOptions")!!)
                                .sdkOptions(call.argument<Int>("sdkOptions")!!)
                                .build()
                        TruecallerSDK.init(trueScope)
                        initialized = true
                        result.success("Truecaller SDK initialized")
                    } else result.success("Truecaller SDK already initialized")
                } catch (e: Exception) {
                    initialized = false
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
                        this.getProfileCalled = true
                        TruecallerSDK.getInstance().getUserProfile((this.activity as FragmentActivity?)!!)
                        result.success("")
                    } else {
                        this.getProfileCalled = false
                        result.error("ERROR", "Truecaller SDK not initialized", false)
                    }
                } catch (e: Exception) {
                    this.getProfileCalled = false
                    result.error("FAILED", e.message, null)
                }
            }
            "phone" -> {
                try {
                    if (initialized) {
                        this.mobile = "+91" + call.arguments.toString()
                        TruecallerSDK.getInstance().requestVerification("IN", call
                                .arguments.toString(), getCallBack(result), (activity as FragmentActivity?)!!)
                    } else
                        result.error("ERROR", "Truecaller SDK not initialized", false)
                } catch (e: Exception) {
                    result.error("FAILED", e.message, null)
                }
            }
            "verifyOTP" -> {
                val userProfile = TrueProfile.Builder(call
                        .argument("firstName")!!, call
                        .argument("lastName")!!).build()
                result.success("")
                verifyOTP(userProfile, call.argument("otp")!!)
            }
        }
    }

    private val sdkCallback: ITrueCallback = object : ITrueCallback {
        override fun onSuccessProfileShared(trueProfile: TrueProfile) {
            // This method is invoked when either the truecaller app is installed on the device and the user gives his
            // consent to share his truecaller profile OR when the user has already been verified before on the same
            // device using the same number and hence does not need OTP to verify himself again.
            getProfileCalled = false
            channel?.invokeMethod("callback", "User verified without OTP")
            channel?.invokeMethod("profile", trueProfileToJson(trueProfile, "User verified without OTP").toString())
            channel?.invokeMethod("verificationRequired", false)
        }

        override fun onFailureProfileShared(trueError: TrueError) {
            // This method is invoked when some error occurs or if an invalid request for verification is made
            getProfileCalled = false
            channel?.invokeMethod("error", trueError.errorType.toString())
            channel?.invokeMethod("verificationRequired", false)
//            Log.d("truecaller-testing", "onFailureProfileShared: " + trueError.errorType)
        }

        override fun onVerificationRequired(trueError: TrueError?) {
            // This method is invoked when truecaller app is not present on the device or if the user wants to
            // continue with a different number and hence, missed call verification is required to complete the flow
            // You can initiate the missed call verification flow from within this callback method by using :
//            Log.d("truecaller-testing", "Please call manual verification method")
            getProfileCalled = false
            channel!!.invokeMethod("verificationRequired", true)
            if (trueError != null)
                channel!!.invokeMethod("error", trueError.errorType.toString())
            else
                channel!!.invokeMethod("callback", "Please call manual verification method")
        }
    }

    private fun getCallBack(result: Result? = null, profile: TrueProfile? = null): VerificationCallback {
        return object : VerificationCallback {
            override fun onRequestSuccess(requestCode: Int, @Nullable extras: VerificationDataBundle?) {

                when (requestCode) {
                    VerificationCallback.TYPE_MISSED_CALL_INITIATED -> {
//                        Log.d("truecaller-testing", "drop call is successfully initiated")
                        result?.success(false)
                        channel?.invokeMethod("callback", "TYPE_MISSED_CALL_INITIATED")
                    }
                    VerificationCallback.TYPE_MISSED_CALL_RECEIVED -> {
//                        Log.d("truecaller-testing", "drop call is successfully detected")
                        channel?.setMethodCallHandler { call, result ->
                            if (call.method == "verifyMissCall") {
                                val userProfile = TrueProfile.Builder(call
                                        .argument("firstName")!!, call
                                        .argument("lastName")!!).build()
                                result.success("")
                                verifyMissedCall(userProfile)
                            }
                        }
                        channel?.invokeMethod("callback", "TYPE_MISSED_CALL_RECEIVED")
                    }
                    VerificationCallback.TYPE_OTP_INITIATED -> {
//                        Log.d("truecaller-testing", "OTP is successfully triggered")
                        result?.success(true)
                        channel?.invokeMethod("callback", "TYPE_OTP_INITIATED")
                    }
                    VerificationCallback.TYPE_OTP_RECEIVED -> {
//                        Log.d("truecaller-testing", "OTP is successfully detected")
                        channel?.setMethodCallHandler { call, result ->
                            if (call.method == "verifyOTP") {
                                val userProfile = TrueProfile.Builder(call
                                        .argument("firstName")!!, call
                                        .argument("lastName")!!).build()
                                result.success("")
                                verifyOTP(userProfile, extras!!.getString(VerificationDataBundle.KEY_OTP)!!)
                            }
                        }
                        channel?.invokeMethod("callback", "TYPE_OTP_RECEIVED")
                    }
                    VerificationCallback.TYPE_VERIFICATION_COMPLETE -> {
                        channel?.invokeMethod("profile", trueProfileToJson(profile!!, "").toString())
                        channel?.invokeMethod("callback", "TYPE_VERIFICATION_COMPLETE")
                    }
                    VerificationCallback.TYPE_PROFILE_VERIFIED_BEFORE -> {
                        channel?.invokeMethod("profile", trueProfileToJson(extras?.profile!!, "").toString())
                        channel?.invokeMethod("callback", "TYPE_PROFILE_VERIFIED_BEFORE")
                        result?.success(false)
                    }
                }
            }

            override fun onRequestFailure(requestCode: Int, e: TrueException) {
                val item = JSONObject()
                item.put("code", e.exceptionType)
                item.put("message", e.exceptionMessage)
                channel?.invokeMethod("error", item.toString())
            }
        }
    }

    fun trueProfileToJson(profile: TrueProfile, verificationMode: String): JSONObject {
        val item = JSONObject()
        item.put("firstName", profile.firstName)
        item.put("lastName", profile.lastName)
        if (profile.phoneNumber != null) {
            if (profile.phoneNumber.startsWith("+"))
                item.put("phoneNumber", profile.phoneNumber)
            else item.put("phoneNumber", "+" + profile.phoneNumber)
        } else
            item.put("phoneNumber", this.mobile)
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
        binding.addActivityResultListener { _, resultCode, intent -> if (this.initialized && this.getProfileCalled) TruecallerSDK.getInstance().onActivityResultObtained((this.activity as FragmentActivity?)!!, resultCode, intent) else true }
        channel?.setMethodCallHandler(this)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
        binding.addActivityResultListener { _, resultCode, intent -> if (this.initialized && this.getProfileCalled) TruecallerSDK.getInstance().onActivityResultObtained((this.activity as FragmentActivity?)!!, resultCode, intent) else true }
    }


    override fun onDetachedFromActivity() {
        activity = null
        channel?.setMethodCallHandler(null)
    }
}
