import json
import urllib.request
import urllib.error
from datetime import datetime

PROJECT_ID = "justus-b131a"
BASE_URL = f"https://firestore.googleapis.com/v1/projects/{PROJECT_ID}/databases/(default)/documents"

def to_firestore_value(val):
    if val is None:
        return {"nullValue": None}
    elif isinstance(val, bool):
        return {"booleanValue": val}
    elif isinstance(val, int):
        return {"integerValue": str(val)}
    elif isinstance(val, float):
        return {"doubleValue": val}
    elif isinstance(val, str):
        return {"stringValue": val}
    elif isinstance(val, list):
        return {"arrayValue": {"values": [to_firestore_value(x) for x in val]}}
    elif isinstance(val, dict):
        return {"mapValue": {"fields": {k: to_firestore_value(v) for k, v in val.items()}}}
    return {"stringValue": str(val)}

def write_document(collection_path, doc_id, data):
    url = f"{BASE_URL}/{collection_path}/{doc_id}"
    fields = {k: to_firestore_value(v) for k, v in data.items()}
    body = json.dumps({"fields": fields}).encode('utf-8')
    
    req = urllib.request.Request(
        url,
        data=body,
        headers={"Content-Type": "application/json"},
        method="PATCH"
    )
    try:
        with urllib.request.urlopen(req) as resp:
            print(f"✓ Saved {collection_path}/{doc_id}")
            return True
    except urllib.error.HTTPError as e:
        print(f"✗ Error saving {collection_path}/{doc_id}: {e.code} - {e.read().decode('utf-8')}")
        return False
    except Exception as e:
        print(f"✗ Exception {collection_path}/{doc_id}: {e}")
        return False

# 1. Services Data
services = [
    {
        "id": "ac_jet_service",
        "category": "ac",
        "titleEn": "AC Deep Jet Cleaning & Filter Wash",
        "titleMr": "एसी डीप जेट क्लिनिंग व फिल्टर वॉश",
        "descriptionEn": "High-pressure indoor foam jet wash, cooling coil sanitization, drainage pipe unclogging & gas leakage checkup.",
        "descriptionMr": "हाय-प्रेशर इनडोअर फोम जेट वॉश, कुलिंग कॉइल निर्जंतुकीकरण, ड्रेनेज पाईप स्वच्छता आणि गॅस तपासणी.",
        "basePrice": 499.0,
        "originalPrice": 799.0,
        "durationMinutes": 45,
        "rating": 4.9,
        "reviewsCount": 340,
        "warrantyDays": 60,
        "inclusions": [
            "Indoor cooling coil foam jet wash",
            "Blower & drain tray deep flush",
            "Outdoor condenser unit wash",
            "Performance & cooling test",
        ],
        "exclusions": ["Spare parts replacement", "Gas charging"],
    },
    {
        "id": "ac_gas_charge",
        "category": "ac",
        "titleEn": "AC Gas Refill & Leakage Arrest",
        "titleMr": "एसी गॅस चार्जिंग व लिकेज दुरुस्ती",
        "descriptionEn": "Nitrogen pressure testing, brazing leakage repair, vacuuming, and 100% pure genuine refrigerant gas top-up.",
        "descriptionMr": "नायट्रोजन प्रेशर टेस्टिंग, ब्रेझिंगद्वारे लिकेज दुरुस्ती, व्हॅक्यूमिंग व १००% खात्रीशीर गॅस रीफिलिंग.",
        "basePrice": 1799.0,
        "originalPrice": 2499.0,
        "durationMinutes": 60,
        "rating": 4.85,
        "reviewsCount": 210,
        "warrantyDays": 90,
        "inclusions": [
            "Complete leak identification",
            "Vacuum pump deep evacuation",
            "Standard refrigerant top-up",
            "Amperage & temperature tuning",
        ],
        "exclusions": ["Compressor internal mechanical failure"],
    },
    {
        "id": "ro_standard_service",
        "category": "roWater",
        "titleEn": "RO Purifier Periodic Filter Service",
        "titleMr": "आरओ फिल्टर सर्व्हिस व टीडीएस तपासणी",
        "descriptionEn": "Sediment filter flush, pre-carbon filter wash, membrane pressure test, TDS level balancing & sanitizer flush.",
        "descriptionMr": "सेडिमेंट फिल्टर फ्लश, कार्बन फिल्टर वॉश, मेम्ब्रेन प्रेशर टेस्ट, टीडीएस लेव्हल बॅलन्सिंग आणि निर्जंतुकीकरण.",
        "basePrice": 299.0,
        "originalPrice": 449.0,
        "durationMinutes": 35,
        "rating": 4.9,
        "reviewsCount": 420,
        "warrantyDays": 30,
        "inclusions": [
            "Spun filter cleaning / check",
            "TDS meter input & output test",
            "SMPS adapter voltage test",
            "Tank sanitization",
        ],
        "exclusions": ["RO membrane replacement cost", "Pump replacement"],
    },
    {
        "id": "ro_filter_change",
        "category": "roWater",
        "titleEn": "RO Complete Filter Kit Replacement",
        "titleMr": "आरओ संपूर्ण फिल्टर किट बदलणे",
        "descriptionEn": "Replacement of pre-carbon, post-carbon, sediment cartridge, mineral cartridge and high-TDS membrane.",
        "descriptionMr": "प्री-कार्बन, पोस्ट-कार्बन, सेडिमेंट काड्रीज, मिनरल काड्रीज आणि हाय-टीडीएस मेम्ब्रेन बदलणे.",
        "basePrice": 1499.0,
        "originalPrice": 2199.0,
        "durationMinutes": 50,
        "rating": 4.95,
        "reviewsCount": 380,
        "warrantyDays": 180,
        "inclusions": [
            "Certified multi-stage filter cartridges",
            "Complete tubing connector overhaul",
            "Post-service TDS tuning to 80-120 ppm",
        ],
        "exclusions": ["Booster pump mechanical repair"],
    },
    {
        "id": "wm_deep_clean",
        "category": "washingMachine",
        "titleEn": "Washing Machine Deep Descaling & Checkup",
        "titleMr": "वॉशिंग मशीन डीप डिगेलिंग व तपासणी",
        "descriptionEn": "Drum tub cleaning, lint filter wash, motor vibration check & drainage troubleshooting.",
        "descriptionMr": "ड्रम टब स्वच्छता, लिंट फिल्टर वॉश, मोटर व्हायब्रेशन चेक व ड्रेनेज दुरुस्ती.",
        "basePrice": 399.0,
        "originalPrice": 599.0,
        "durationMinutes": 45,
        "rating": 4.7,
        "reviewsCount": 190,
        "warrantyDays": 30,
        "inclusions": [
            "Full automatic tub chemical descaling",
            "Inlet & outlet hose check",
            "Spin & agitation test",
        ],
        "exclusions": ["Electronic PCB repair"],
    },
    {
        "id": "fridge_cooling_repair",
        "category": "refrigerator",
        "titleEn": "Refrigerator Cooling & Compressor Diagnostics",
        "titleMr": "फ्रीज कुलिंग व कॉम्प्रेसर दुरुस्ती",
        "descriptionEn": "Thermostat inspection, defrost timer check, gas level test & door gasket replacement.",
        "descriptionMr": "थर्मोस्टॅट तपासणी, डीफ्रॉस्ट टाइमर चेक, गॅस लेव्हल टेस्ट आणि दरवाजा गॅस्केट बदल.",
        "basePrice": 349.0,
        "originalPrice": 499.0,
        "durationMinutes": 40,
        "rating": 4.8,
        "reviewsCount": 160,
        "warrantyDays": 30,
        "inclusions": [
            "Complete diagnostics",
            "Door seal inspection",
            "Coil cleaning",
        ],
        "exclusions": ["Compressor cost", "Relay/OLP parts"],
    },
    {
        "id": "plumbing_fitting",
        "category": "plumbing",
        "titleEn": "Plumbing Fitting & Leakage Solution",
        "titleMr": "प्लंबर - नळ, पाईप फिटिंग व लिकेज दुरुस्ती",
        "descriptionEn": "Expert plumber visit for pipe fitting, tap installation, toilet flush & concealed leakage.",
        "descriptionMr": "तज्ज्ञ प्लंबर भेट: पाईप फिटिंग, नळ बसवणे, टॉयलेट फ्लश व लिकेज निराकरण.",
        "basePrice": 249.0,
        "originalPrice": 399.0,
        "durationMinutes": 45,
        "rating": 4.8,
        "reviewsCount": 512,
        "warrantyDays": 30,
        "inclusions": [
            "Up to 1 hour of labor for fitting/repairs",
            "Pressure & joint leakage testing",
            "All installation tools included",
        ],
        "exclusions": ["Hardware & pipe materials cost"],
    },
    {
        "id": "electrical_fitting",
        "category": "electrical",
        "titleEn": "Electrician Fitting & MCB Inspection",
        "titleMr": "इलेक्ट्रिशियन - स्वीचबोर्ड, वायरिंग व फिटिंग",
        "descriptionEn": "Switchboard installation, short-circuit troubleshooting, fan/geyser wiring & MCB setup.",
        "descriptionMr": "स्वीचबोर्ड बसवणे, शॉर्ट-सर्किट तपासणी, फॅन/गिझर वायरिंग व एमसीबी इन्स्टॉलेशन.",
        "basePrice": 249.0,
        "originalPrice": 399.0,
        "durationMinutes": 40,
        "rating": 4.9,
        "reviewsCount": 390,
        "warrantyDays": 30,
        "inclusions": [
            "Wiring continuity check",
            "Earth testing",
            "Installation labor",
        ],
        "exclusions": ["Electrical wires, switches, MCBs"],
    },
    {
        "id": "geyser_maintenance",
        "category": "geyser",
        "titleEn": "Geyser Deep Descaling & Element Check",
        "titleMr": "गिझर डीप क्लिनिंग व कॉइल तपासणी",
        "descriptionEn": "Full heating element scale removal, thermostat calibration, pressure valve test & water flow tuning.",
        "descriptionMr": "हिटिंग कॉइलवरील क्षार साफ करणे, थर्मोस्टॅट तपासणी व प्रेशर व्हॉल्व्ह सुरक्षितता चाचणी.",
        "basePrice": 349.0,
        "originalPrice": 499.0,
        "durationMinutes": 45,
        "rating": 4.85,
        "reviewsCount": 280,
        "warrantyDays": 30,
        "inclusions": [
            "Tank draining and scale flushing",
            "Heating element inspection",
            "Safety valve and thermostat check",
        ],
        "exclusions": ["Replacement of heating element or thermostat"],
    },
    {
        "id": "chimney_deep_clean",
        "category": "chimney",
        "titleEn": "Kitchen Chimney & Filter Degreasing",
        "titleMr": "किचन चिमणी व फिल्टर ऑइल डिग्रेसिंग",
        "descriptionEn": "Heavy oil baffle filter degreasing, motor impeller cleaning, outer stainless steel polish & suction check.",
        "descriptionMr": "चिमणी बॅफल फिल्टरवरील तेल साफ करणे, मोटर ब्लोअर स्वच्छता व सक्शन पॉवर चाचणी.",
        "basePrice": 499.0,
        "originalPrice": 799.0,
        "durationMinutes": 60,
        "rating": 4.82,
        "reviewsCount": 310,
        "warrantyDays": 30,
        "inclusions": [
            "Baffle / mesh filter chemical degreasing",
            "Oil collector cup emptying and wash",
            "Blower fan motor dust removal",
        ],
        "exclusions": ["Duct pipe replacement", "Motor replacement"],
    },
]

# 2. Super Admin User Account
admin_user = {
    "id": "admin_01",
    "name": "Super Admin",
    "email": "admin@gmail.com",
    "password": "password123",
    "phone": "9822000000",
    "role": "admin",
    "createdAt": datetime.utcnow().isoformat() + "Z"
}

# 3. App Metadata Document
metadata = {
    "appName": "Home Appliances On-Demand",
    "node": "homeappliance",
    "status": "Active & Live Connected",
    "database": "Cloud Firestore",
    "version": "1.0.0",
    "totalServices": len(services),
    "totalUsers": 1,
    "lastSyncedAt": datetime.utcnow().isoformat() + "Z",
}

print("\n--- 1. Writing homeappliance root node documents ---")
write_document("homeappliance", "metadata", metadata)
write_document("homeappliance", "overview", {
    "appName": "Home Appliances On-Demand",
    "description": "Smart appliance servicing, AMC tracking & express repair system",
    "categories": ["AC", "RO Water", "Washing Machine", "Refrigerator", "Plumbing", "Electrical", "Geyser", "Chimney"],
    "warrantyCoverage": "Up to 90 Days Comprehensive",
    "created": datetime.utcnow().isoformat() + "Z"
})

print("\n--- 2. Writing services collection ---")
for s in services:
    write_document("services", s["id"], s)

print("\n--- 3. Writing users collection ---")
write_document("users", admin_user["id"], admin_user)

print("\n--- 4. Writing metadata collection ---")
write_document("metadata", "homeappliance", metadata)

print("\n--- 5. Done! All collections successfully populated in Cloud Firestore! ---")
