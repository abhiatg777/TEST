public class QS_CSS_Statics {
    
	static QS_Settings__mdt sQS_Settings;
	public static QS_Settings__mdt QS_Settings {get{

		if (sQS_Settings == null) {
			sQS_Settings = (QS_Settings__mdt)QS_VCG_Utils.GetObject('QS_Settings__mdt', ' developername = \'QS_Settings\'')[0];
		}
		return sQS_Settings;
	}}

}