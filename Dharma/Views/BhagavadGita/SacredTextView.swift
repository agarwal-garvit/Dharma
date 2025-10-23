//
//  SacredTextView.swift
//  Dharma
//
//  Created by Garvit Agarwal on 9/28/25.
//

import SwiftUI

struct SacredTextView: View {
    @State private var dataManager = DataManager.shared
    @State private var selectedChapter: Int = 1
    @State private var isLoading = false
    
    // Fixed to Bhagavad Gita for now
    private let selectedText: SacredTextType = .bhagavadGita
    
    private var currentText: SacredText {
        SacredText(type: selectedText)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background color
                ThemeManager.appBackground
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Chapter selector
                    chapterSelector
                    
                    // Content area - book-like page
                    if isLoading {
                        loadingView
                    } else {
                        bookPageView
                    }
                }
            }
            .navigationTitle("Bhagavad Gita")
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            loadChapterContent()
        }
        .onChange(of: selectedChapter) {
            loadChapterContent()
        }
    }
    
    private var chapterSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(1...currentText.totalChapters, id: \.self) { chapter in
                    Button(action: {
                        selectedChapter = chapter
                    }) {
                        Text("Ch. \(chapter)")
                            .font(.subheadline)
                            .fontWeight(selectedChapter == chapter ? .semibold : .regular)
                            .foregroundColor(selectedChapter == chapter ? .white : .primary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(selectedChapter == chapter ? Color.orange : Color(.systemGray5))
                            )
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
        .background(Color(.systemBackground))
    }
    
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
            
            Text("Loading \(currentText.title) Chapter \(selectedChapter)...")
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var bookPageView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Chapter title
                VStack(alignment: .center, spacing: 8) {
                    Text("Chapter \(selectedChapter)")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text(getChapterTitle(selectedChapter))
                        .font(.title3)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.bottom, 24)
                
                // Verses displayed as continuous text
                ForEach(1...getVerseCount(for: selectedChapter), id: \.self) { verse in
                    VStack(alignment: .leading, spacing: 12) {
                        // Verse number
                        Text("\(selectedChapter).\(verse)")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.orange)
                        
                        // Get actual verse content
                        let verseContent = getVerseContent(chapter: selectedChapter, verse: verse)
                        
                        // Sanskrit text
                        Text(verseContent.sanskrit)
                            .font(.body)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                            .lineSpacing(4)
                        
                        // Transliteration
                        Text(verseContent.transliteration)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .italic()
                            .lineSpacing(2)
                        
                        // Translation
                        Text(verseContent.translation)
                            .font(.body)
                            .foregroundColor(.primary)
                            .lineSpacing(2)
                    }
                    .padding(.bottom, 20)
                }
            }
            .padding(24)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
            )
            .padding(16)
        }
    }
    
    private func loadChapterContent() {
        isLoading = true
        
        // Simulate loading delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            isLoading = false
        }
        
        // TODO: Implement actual server API call
        // await dataManager.loadChapter(selectedChapter)
    }
    
    private func getChapterTitle(_ chapter: Int) -> String {
        let titles = [
            1: "Arjuna's Despair",
            2: "Sankhya Yoga",
            3: "Karma Yoga",
            4: "Jnana Yoga",
            5: "Karma Sannyasa Yoga",
            6: "Dhyana Yoga",
            7: "Jnana Vijnana Yoga",
            8: "Akshara Brahma Yoga",
            9: "Raja Vidya Yoga",
            10: "Vibhuti Yoga",
            11: "Vishvarupa Darshana Yoga",
            12: "Bhakti Yoga",
            13: "Kshetra Kshetrajna Yoga",
            14: "Gunatraya Vibhaga Yoga",
            15: "Purushottama Yoga",
            16: "Daivasura Sampad Vibhaga Yoga",
            17: "Shraddhatraya Vibhaga Yoga",
            18: "Moksha Sannyasa Yoga"
        ]
        return titles[chapter] ?? "Chapter \(chapter)"
    }
    
    private func getVerseCount(for chapter: Int) -> Int {
        let counts = [
            1: 47, 2: 72, 3: 43, 4: 42, 5: 29,
            6: 47, 7: 30, 8: 28, 9: 34, 10: 42,
            11: 55, 12: 20, 13: 35, 14: 27, 15: 20,
            16: 24, 17: 28, 18: 78
        ]
        return counts[chapter] ?? 20
    }
    
    private func getVerseContent(chapter: Int, verse: Int) -> (sanskrit: String, transliteration: String, translation: String) {
        // Chapter 1 verses
        if chapter == 1 {
            let chapter1Verses: [Int: (sanskrit: String, transliteration: String, translation: String)] = [
                1: (
                    "धृतराष्ट्र उवाच\nधर्मक्षेत्रे कुरुक्षेत्रे समवेता युयुत्सवः।\nमामकाः पाण्डवाश्चैव किमकुर्वत सञ्जय॥",
                    "dhṛtarāṣṭra uvāca\ndharma-kṣetre kuru-kṣetre samavetā yuyutsavaḥ\nmāmakāḥ pāṇḍavāś caiva kim akurvata sañjaya",
                    "Dhritarashtra said: O Sanjaya, what did my sons and the sons of Pandu do when they assembled on the sacred field of Kurukshetra, eager for battle?"
                ),
                2: (
                    "सञ्जय उवाच\nदृष्ट्वा तु पाण्डवानीकं व्यूढं दुर्योधनस्तदा।\nआचार्यमुपसङ्गम्य राजा वचनमब्रवीत्॥",
                    "sañjaya uvāca\ndṛṣṭvā tu pāṇḍavānīkaṁ vyūḍhaṁ duryodhanas tadā\nācāryam upasaṅgamya rājā vacanam abravīt",
                    "Sanjaya said: O King, after looking over the army arranged in military formation by the sons of Pandu, King Duryodhana went to his teacher and spoke these words:"
                ),
                3: (
                    "पश्यैतां पाण्डुपुत्राणामाचार्य महतीं चमूम्।\nव्यूढां द्रुपदपुत्रेण तव शिष्येण धीमता॥",
                    "paśyaitāṁ pāṇḍu-putrāṇām ācārya mahatīṁ camūm\nvyūḍhāṁ drupada-putreṇa tava śiṣyeṇa dhīmatā",
                    "O my teacher, behold the great army of the sons of Pandu, so expertly arranged by your intelligent disciple, the son of Drupada."
                ),
                4: (
                    "अत्र शूरा महेष्वासा भीमार्जुनसमा युधि।\nयुयुधानो विराटश्च द्रुपदश्च महारथः॥",
                    "atra śūrā maheṣvāsā bhīmārjuna-samā yudhi\nyuyudhāno virāṭaś ca drupadaś ca mahā-rathaḥ",
                    "Here in this army are many heroic bowmen equal in fighting to Bhima and Arjuna: great fighters like Yuyudhana, Virata and Drupada."
                ),
                5: (
                    "धृष्टकेतुश्चेकितानः काशिराजश्च वीर्यवान्।\nपुरुजित्कुन्तिभोजश्च शैब्यश्च नरपुङ्गवः॥",
                    "dhṛṣṭaketuś cekitānaḥ kāśirājaś ca vīryavān\npurujit kuntibhojaś ca śaibyaś ca nara-puṅgavaḥ",
                    "There are also great, heroic, powerful fighters like Dhrishtaketu, Chekitana, Kashiraja, Purujit, Kuntibhoja and Shaibya."
                ),
                6: (
                    "युधामन्युश्च विक्रान्त उत्तमौजाश्च वीर्यवान्।\nसौभद्रो द्रौपदेयाश्च सर्व एव महारथाः॥",
                    "yudhāmanyuś ca vikrānta uttamaujāś ca vīryavān\nsaubhadro draupadeyāś ca sarva eva mahā-rathāḥ",
                    "The strong Yudhamanyu, the very powerful Uttamauja, the son of Subhadra and the sons of Draupadi all command great chariot divisions."
                ),
                7: (
                    "अस्माकं तु विशिष्टा ये तान्निबोध द्विजोत्तम।\nनायका मम सैन्यस्य संज्ञार्थं तान्ब्रवीमि ते॥",
                    "asmākaṁ tu viśiṣṭā ye tān nibodha dvijottama\nnāyakā mama sainyasya saṁjñārthaṁ tān bravīmi te",
                    "But for your information, O best of the brahmanas, let me tell you about the captains who are especially qualified to lead my military force."
                ),
                8: (
                    "भवान्भीष्मश्च कर्णश्च कृपश्च समितिञ्जयः।\nअश्वत्थामा विकर्णश्च सौमदत्तिस्तथैव च॥",
                    "bhavān bhīṣmaś ca karṇaś ca kṛpaś ca samitiñjayaḥ\naśvatthāmā vikarṇaś ca saumadattis tathaiva ca",
                    "There are personalities like you, Bhishma, Karna, Kripa, Ashvatthama, Vikarna and the son of Somadatta called Bhurishrava, who are always victorious in battle."
                ),
                9: (
                    "अन्ये च बहवः शूरा मदर्थे त्यक्तजीविताः।\nनानाशस्त्रप्रहरणाः सर्वे युद्धविशारदाः॥",
                    "anye ca bahavaḥ śūrā mad-arthe tyakta-jīvitāḥ\nnānā-śastra-praharaṇāḥ sarve yuddha-viśāradāḥ",
                    "There are many other heroes who are prepared to lay down their lives for my sake. All of them are well equipped with different kinds of weapons, and all are experienced in military science."
                ),
                10: (
                    "अपर्याप्तं तदस्माकं बलं भीष्माभिरक्षितम्।\nपर्याप्तं त्विदमेतेषां बलं भीमाभिरक्षितम्॥",
                    "aparyāptaṁ tad asmākaṁ balaṁ bhīṣmābhirakṣitam\nparyāptaṁ tv idam eteṣāṁ balaṁ bhīmābhirakṣitam",
                    "Our strength is immeasurable, and we are perfectly protected by Grandfather Bhishma, whereas the strength of the Pandavas, carefully protected by Bhima, is limited."
                ),
                11: (
                    "अयनेषु च सर्वेषु यथाभागमवस्थिताः।\nभीष्ममेवाभिरक्षन्तु भवन्तः सर्व एव हि॥",
                    "ayaneṣu ca sarveṣu yathā-bhāgam avasthitāḥ\nbhīṣmam evābhirakṣantu bhavantaḥ sarva eva hi",
                    "All of you must now give full support to Grandfather Bhishma, as you stand at your respective strategic points of entrance into the phalanx of the army."
                ),
                12: (
                    "तस्य सञ्जनयन्हर्षं कुरुवृद्धः पितामहः।\nसिंहनादं विनद्योच्चैः शङ्खं दध्मौ प्रतापवान्॥",
                    "tasya sañjanayan harṣaṁ kuru-vṛddhaḥ pitāmahaḥ\nsiṁha-nādaṁ vinadyoccaiḥ śaṅkhaṁ dadhmau pratāpavān",
                    "Then Bhishma, the great valiant grandsire of the Kuru dynasty, the grandfather of the fighters, blew his conchshell very loudly, making a sound like the roar of a lion, giving Duryodhana joy."
                ),
                13: (
                    "ततः शङ्खाश्च भेर्यश्च पणवानकगोमुखाः।\nसहसैवाभ्यहन्यन्त स शब्दस्तुमुलोऽभवत्॥",
                    "tataḥ śaṅkhāś ca bheryaś ca paṇavānaka-gomukhāḥ\nsahasaivābhyahanyanta sa śabdas tumulo 'bhavat",
                    "After that, the conchshells, drums, bugles, trumpets and horns were all suddenly sounded, and the combined sound was tumultuous."
                ),
                14: (
                    "ततः श्वेतैर्हयैर्युक्ते महति स्यन्दने स्थितौ।\nमाधवः पाण्डवश्चैव दिव्यौ शङ्खौ प्रदध्मतुः॥",
                    "tataḥ śvetair hayair yukte mahati syandane sthitau\nmādhavaḥ pāṇḍavaś caiva divyau śaṅkhau pradadhmatuḥ",
                    "On the other side, both Lord Krishna and Arjuna, stationed on a great chariot drawn by white horses, sounded their transcendental conchshells."
                ),
                15: (
                    "पाञ्चजन्यं हृषीकेशो देवदत्तं धनञ्जयः।\nपौण्ड्रं दध्मौ महाशङ्खं भीमकर्मा वृकोदरः॥",
                    "pāñcajanyaṁ hṛṣīkeśo devadattaṁ dhanañjayaḥ\npauṇḍraṁ dadhmau mahā-śaṅkhaṁ bhīma-karmā vṛkodaraḥ",
                    "Lord Krishna blew His conchshell, called Pancajanya; Arjuna blew his, the Devadatta; and Bhima, the voracious eater and performer of Herculean tasks, blew his terrific conchshell called Paundram."
                ),
                16: (
                    "अनन्तविजयं राजा कुन्तीपुत्रो युधिष्ठिरः।\nनकुलः सहदेवश्च सुघोषमणिपुष्पकौ॥",
                    "ananta-vijayaṁ rājā kuntī-putro yudhiṣṭhiraḥ\nnakulaḥ sahadevaś ca sughoṣa-maṇipuṣpakau",
                    "King Yudhishthira, the son of Kunti, blew his conchshell, the Ananta-vijaya, and Nakula and Sahadeva blew the Sughosha and Manipushpaka."
                ),
                17: (
                    "काश्यश्च परमेष्वासः शिखण्डी च महारथः।\nधृष्टद्युम्नो विराटश्च सात्यकिश्चापराजितः॥",
                    "kāśyaś ca parameṣvāsaḥ śikhaṇḍī ca mahā-rathaḥ\ndhṛṣṭadyumno virāṭaś ca sātyakiś cāparājitaḥ",
                    "That great archer the King of Kashi, the great fighter Shikhandi, Dhrishtadyumna, Virata and the unconquerable Satyaki, Drupada, the sons of Draupadi, and others, O King, such as the mighty-armed son of Subhadra, all blew their respective conchshells."
                ),
                18: (
                    "द्रुपदो द्रौपदेयाश्च सर्वशः पृथिवीपते।\nसौभद्रश्च महाबाहुः शङ्खान्दध्मुः पृथक्पृथक्॥",
                    "drupado draupadeyāś ca sarvaśaḥ pṛthivī-pate\nsaubhadraś ca mahā-bāhuḥ śaṅkhān dadhmuḥ pṛthak pṛthak",
                    "The blowing of these different conchshells became uproarious. Vibrating both in the sky and on the earth, it shattered the hearts of the sons of Dhritarashtra."
                ),
                19: (
                    "स घोषो धार्तराष्ट्राणां हृदयानि व्यदारयत्।\nनभश्च पृथिवीं चैव तुमुलो व्यनुनादयन्॥",
                    "sa ghoṣo dhārtarāṣṭrāṇāṁ hṛdayāni vyadārayat\nnabhaś ca pṛthivīṁ caiva tumulo vyanunādayan",
                    "At that time Arjuna, the son of Pandu, seated in the chariot bearing the flag marked with Hanuman, took up his bow and prepared to shoot his arrows, O King. After looking at the sons of Dhritarashtra drawn in military array, Arjuna then spoke to Lord Krishna these words."
                ),
                20: (
                    "अथ व्यवस्थितान्दृष्ट्वा धार्तराष्ट्रान्कपिध्वजः।\nप्रवृत्ते शस्त्रसम्पाते धनुरुद्यम्य पाण्डवः॥",
                    "atha vyavasthitān dṛṣṭvā dhārtarāṣṭrān kapi-dhvajaḥ\npravṛtte śastra-sampāte dhanur udyamya pāṇḍavaḥ",
                    "Arjuna said: O infallible one, please draw my chariot between the two armies so that I may see those present here, who desire to fight, and with whom I must contend in this great trial of arms."
                ),
                21: (
                    "हृषीकेशं तदा वाक्यमिदमाह महीपते।\nसेनयोरुभयोर्मध्ये रथं स्थापय मेऽच्युत॥",
                    "hṛṣīkeśaṁ tadā vākyam idam āha mahī-pate\nsenayor ubhayor madhye rathaṁ sthāpaya me 'cyuta",
                    "Let me see those who have come here to fight, wishing to please the evil-minded son of Dhritarashtra."
                ),
                22: (
                    "यावदेतान्निरीक्षेऽहं योद्धुकामानवस्थितान्।\nकैर्मया सह योद्धव्यमस्मिन्रणसमुद्यमे॥",
                    "yāvad etān nirīkṣe 'haṁ yoddhu-kāmān avasthitān\nkair mayā saha yoddhavyam asmin raṇa-samudyame",
                    "Sanjaya said: O descendant of Bharata, having thus been addressed by Arjuna, Lord Krishna drew up the fine chariot in the midst of the armies of both parties."
                ),
                23: (
                    "योत्स्यमानानवेक्षेऽहं य एतेऽत्र समागताः।\nधार्तराष्ट्रस्य दुर्बुद्धेर्युद्धे प्रियचिकीर्षवः॥",
                    "yotsyamānān avekṣe 'haṁ ya ete 'tra samāgatāḥ\ndhārtarāṣṭrasya durbuddher yuddhe priya-cikīrṣavaḥ",
                    "In the presence of Bhishma, Drona and all the other chieftains of the world, the Lord said: Just behold, Partha, all the Kurus assembled here."
                ),
                24: (
                    "एवमुक्तो हृषीकेशो गुडाकेशेन भारत।\nसेनयोरुभयोर्मध्ये स्थापयित्वा रथोत्तमम्॥",
                    "evam ukto hṛṣīkeśo guḍākeśena bhārata\nsenayor ubhayor madhye sthāpayitvā rathottamam",
                    "There Arjuna could see, within the midst of the armies of both parties, his fathers, grandfathers, teachers, maternal uncles, brothers, sons, grandsons, friends, and also his fathers-in-law and well-wishers."
                ),
                25: (
                    "भीष्मद्रोणप्रमुखतः सर्वेषां च महीक्षिताम्।\nउवाच पार्थ पश्यैतान्समवेतान्कुरूनिति॥",
                    "bhīṣma-droṇa-pramukhataḥ sarveṣāṁ ca mahī-kṣitām\nuvāca pārtha paśyaitān samavetān kurūn iti",
                    "When the son of Kunti, Arjuna, saw all these different grades of friends and relatives, he became overwhelmed with compassion and spoke thus:"
                ),
                26: (
                    "तत्रापश्यत्स्थितान्पार्थः पितृनथ पितामहान्।\nआचार्यान्मातुलान्भ्रातृन्पुत्रान्पौत्रान्सखींस्तथा॥",
                    "tatrāpaśyat sthitān pārthaḥ pitṛn atha pitāmahān\nācāryān mātulān bhrātṛn putrān pautrān sakhīṁs tathā",
                    "Arjuna said: My dear Krishna, seeing my friends and relatives present before me in such a fighting spirit, I feel the limbs of my body quivering and my mouth drying up."
                ),
                27: (
                    "श्वशुरान्सुहृदश्चैव सेनयोरुभयोरपि।\nतान्समीक्ष्य स कौन्तेयः सर्वान्बन्धूनवस्थितान्॥",
                    "śvaśurān suhṛdaś caiva senayor ubhayor api\ntān samīkṣya sa kaunteyaḥ sarvān bandhūn avasthitān",
                    "My whole body is trembling, my hair is standing on end, my bow Gandiva is slipping from my hand, and my skin is burning."
                ),
                28: (
                    "कृपया परयाऽऽविष्टो विषीदन्निदमब्रवीत्।\nदृष्ट्वेमं स्वजनं कृष्ण युयुत्सुं समुपस्थितम्॥",
                    "kṛpayā parayā 'viṣṭo viṣīdann idam abravīt\ndṛṣṭvemaṁ sva-janaṁ kṛṣṇa yuyutsuṁ samupasthitam",
                    "I am now unable to stand here any longer. I am forgetting myself, and my mind is reeling. I see only causes of misfortune, O Krishna, killer of the Keshi demon."
                ),
                29: (
                    "सीदन्ति मम गात्राणि मुखं च परिशुष्यति।\nवेपथुश्च शरीरे मे रोमहर्षश्च जायते॥",
                    "sīdanti mama gātrāṇi mukhaṁ ca pariśuṣyati\nvepathuś ca śarīre me roma-harṣaś ca jāyate",
                    "I do not see how any good can come from killing my own kinsmen in this battle, nor can I, my dear Krishna, desire any subsequent victory, kingdom, or happiness."
                ),
                30: (
                    "गाण्डीवं स्रंसते हस्तात्त्वक्चैव परिदह्यते।\nन च शक्नोम्यवस्थातुं भ्रमतीव च मे मनः॥",
                    "gāṇḍīvaṁ sraṁsate hastāt tvak caiva paridahyate\nna ca śaknomy avasthātuṁ bhramatīva ca me manaḥ",
                    "O Govinda, of what avail to us are a kingdom, happiness or even life itself when all those for whom we may desire them are now arrayed on this battlefield?"
                ),
                31: (
                    "निमित्तानि च पश्यामि विपरीतानि केशव।\nन च श्रेयोऽनुपश्यामि हत्वा स्वजनमाहवे॥",
                    "nimittāni ca paśyāmi viparītāni keśava\nna ca śreyo 'nupaśyāmi hatvā sva-janam āhave",
                    "O Madhusudana, when teachers, fathers, sons, grandfathers, maternal uncles, fathers-in-law, grandsons, brothers-in-law and other relatives are ready to give up their lives and properties and are standing before me, why should I wish to kill them, even though they might otherwise kill me?"
                ),
                32: (
                    "न काङ्क्षे विजयं कृष्ण न च राज्यं सुखानि च।\nकिं नो राज्येन गोविन्द किं भोगैर्जीवितेन वा॥",
                    "na kāṅkṣe vijayaṁ kṛṣṇa na ca rājyaṁ sukhāni ca\nkiṁ no rājyena govinda kiṁ bhogair jīvitena vā",
                    "O maintainer of all living entities, I am not prepared to fight with them even in exchange for the three worlds, let alone this earth. What pleasure will we derive from killing the sons of Dhritarashtra?"
                ),
                33: (
                    "येषामर्थे काङ्क्षितं नो राज्यं भोगाः सुखानि च।\nत इमेऽवस्थिता युद्धे प्राणांस्त्यक्त्वा धनानि च॥",
                    "yeṣām arthe kāṅkṣitaṁ no rājyaṁ bhogāḥ sukhāni ca\nta ime 'vasthitā yuddhe prāṇāṁs tyaktvā dhanāni ca",
                    "Sin will overcome us if we slay such aggressors. Therefore it is not proper for us to kill the sons of Dhritarashtra and our friends. What should we gain, O Krishna, husband of the goddess of fortune, and how could we be happy by killing our own kinsmen?"
                ),
                34: (
                    "आचार्याः पितरः पुत्रास्तथैव च पितामहाः।\nमातुलाः श्वशुराः पौत्राः श्यालाः सम्बन्धिनस्तथा॥",
                    "ācāryāḥ pitaraḥ putrās tathaiva ca pitāmahāḥ\nmātulāḥ śvaśurāḥ pautrāḥ śyālāḥ sambandhinas tathā",
                    "O Janardana, although these men, overtaken by greed, see no fault in killing one's family or quarreling with friends, why should we, who can see the crime in destroying a family, engage in these acts of sin?"
                ),
                35: (
                    "एतान्न हन्तुमिच्छामि घ्नतोऽपि मधुसूदन।\nअपि त्रैलोक्यराज्यस्य हेतोः किं नु महीकृते॥",
                    "etān na hantum icchāmi ghnato 'pi madhusūdana\napi trailokya-rājyasya hetoḥ kiṁ nu mahī-kṛte",
                    "With the destruction of dynasty, the eternal family tradition is vanquished, and thus the rest of the family becomes involved in irreligion."
                ),
                36: (
                    "निहत्य धार्तराष्ट्रान्नः का प्रीतिः स्याज्जनार्दन।\nपापमेवाश्रयेदस्मान्हत्वैतानाततायिनः॥",
                    "nihatya dhārtarāṣṭrān naḥ kā prītiḥ syāj janārdana\npāpam evāśrayed asmān hatvaitān ātatāyinaḥ",
                    "When irreligion is prominent in the family, O Krishna, the women of the family become corrupt, and from the degradation of womanhood, O descendant of Vrishni, comes unwanted progeny."
                ),
                37: (
                    "तस्मान्नार्हा वयं हन्तुं धार्तराष्ट्रान्स्वबान्धवान्।\nस्वजनं हि कथं हत्वा सुखिनः स्याम माधव॥",
                    "tasmān nārhā vayaṁ hantuṁ dhārtarāṣṭrān sva-bāndhavān\nsva-janaṁ hi kathaṁ hatvā sukhinaḥ syāma mādhava",
                    "When there is increase of unwanted population, a hellish situation is created both for the family and for those who destroy the family tradition. In such corrupt families, there is no offering of oblations of food and water to the ancestors."
                ),
                38: (
                    "यद्यप्येते न पश्यन्ति लोभोपहतचेतसः।\nकुलक्षयकृतं दोषं मित्रद्रोहे च पातकम्॥",
                    "yady apy ete na paśyanti lobhopahata-cetasaḥ\nkula-kṣaya-kṛtaṁ doṣaṁ mitra-drohe ca pātakam",
                    "Due to the evil deeds of the destroyers of family tradition, all kinds of community projects and family welfare activities are devastated."
                ),
                39: (
                    "कथं न ज्ञेयमस्माभिः पापादस्मान्निवर्तितुम्।\nकुलक्षयकृतं दोषं प्रपश्यद्भिर्जनार्दन॥",
                    "kathaṁ na jñeyam asmābhiḥ pāpād asmān nivartitum\nkula-kṣaya-kṛtaṁ doṣaṁ prapaśyadbhir janārdana",
                    "O Krishna, maintainer of the people, I have heard by disciplic succession that those who destroy family traditions dwell always in hell."
                ),
                40: (
                    "अहो बत महत्पापं कर्तुं व्यवसिता वयम्।\nयद्राज्यसुखलोभेन हन्तुं स्वजनमुद्यताः॥",
                    "aho bata mahat pāpaṁ kartuṁ vyavasitā vayam\nyad rājya-sukha-lobhena hantuṁ sva-janam udyatāḥ",
                    "Alas, how strange it is that we are preparing to commit greatly sinful acts. Driven by the desire to enjoy royal happiness, we are intent on killing our own kinsmen."
                ),
                41: (
                    "यदि मामप्रतीकारमशस्त्रं शस्त्रपाणयः।\nधार्तराष्ट्रा रणे हन्युस्तन्मे क्षेमतरं भवेत्॥",
                    "yadi mām apratīkāram aśastraṁ śastra-pāṇayaḥ\ndhārtarāṣṭrā raṇe hanyus tan me kṣemataraṁ bhavet",
                    "Better for me if the sons of Dhritarashtra, weapons in hand, were to kill me unarmed and unresisting on the battlefield."
                ),
                42: (
                    "एवमुक्त्वार्जुनः सङ्ख्ये रथोपस्थ उपाविशत्।\nविसृज्य सशरं चापं शोकसंविग्नमानसः॥",
                    "evam uktvārjunaḥ saṅkhye rathopastha upāviśat\nvisṛjya sa-śaraṁ cāpaṁ śoka-saṁvigna-mānasaḥ",
                    "Sanjaya said: Arjuna, having thus spoken on the battlefield, cast aside his bow and arrows and sat down on the chariot, his mind overwhelmed with grief."
                ),
                43: (
                    "तं तथा कृपयाऽऽविष्टमश्रुपूर्णाकुलेक्षणम्।\nविषीदन्तमिदं वाक्यमुवाच मधुसूदनः॥",
                    "taṁ tathā kṛpayā 'viṣṭam aśru-pūrṇākulekṣaṇam\nviṣīdantam idaṁ vākyam uvāca madhusūdanaḥ",
                    "Thus ends the first chapter of the Srimad Bhagavad-gita, entitled \"Arjuna's Despair.\""
                ),
                44: (
                    "श्रीभगवानुवाच\nकुतस्त्वा कश्मलमिदं विषमे समुपस्थितम्।\nअनार्यजुष्टमस्वर्ग्यमकीर्तिकरमर्जुन॥",
                    "śrī-bhagavān uvāca\nkutas tvā kaśmalam idaṁ viṣame samupasthitam\nanārya-juṣṭam asvargyam akīrti-karam arjuna",
                    "The Supreme Personality of Godhead said: My dear Arjuna, how have these impurities come upon you? They are not at all befitting a man who knows the progressive values of life. They do not lead to higher planets but to infamy."
                ),
                45: (
                    "क्लैब्यं मा स्म गमः पार्थ नैतत्त्वय्युपपद्यते।\nक्षुद्रं हृदयदौर्बल्यं त्यक्त्वोत्तिष्ठ परन्तप॥",
                    "klaibyaṁ mā sma gamaḥ pārtha naitat tvayy upapadyate\nkṣudraṁ hṛdaya-daurbalyaṁ tyaktvottiṣṭha parantapa",
                    "O son of Pritha, do not yield to this degrading impotence. It does not become you. Give up such petty weakness of heart and arise, O chastiser of the enemy."
                ),
                46: (
                    "अर्जुन उवाच\nकथं भीष्ममहं सङ्ख्ये द्रोणं च मधुसूदन।\nइषुभिः प्रतियोत्स्यामि पूजार्हावरिसूदन॥",
                    "arjuna uvāca\nkathaṁ bhīṣmam ahaṁ saṅkhye droṇaṁ ca madhusūdana\niṣubhiḥ pratiyotsyāmi pūjārhāv ari-sūdana",
                    "Arjuna said: O descendant of Madhu, how can I counterattack with arrows in battle men like Bhishma and Drona, who are worthy of my worship, O destroyer of enemies?"
                ),
                47: (
                    "गुरूनहत्वा हि महानुभावान्\nश्रेयो भोक्तुं भैक्ष्यमपीह लोके।\nहत्वार्थकामांस्तु गुरूनिहैव\nभुञ्जीय भोगान्रुधिरप्रदिग्धान्॥",
                    "gurūn ahatvā hi mahānubhāvān\nśreyo bhoktuṁ bhaikṣyam apīha loke\nhatvārtha-kāmāṁs tu gurūn ihaiwa\nbhuñjīya bhogān rudhira-pradigdhān",
                    "It would be better to live in this world by begging than to live at the cost of the lives of great souls who are my teachers. Even though they are avaricious, they are nonetheless superiors. If they are killed, our spoils will be tainted with blood."
                )
            ]
            
            return chapter1Verses[verse] ?? (
                "कर्मण्येवाधिकारस्ते मा फलेषु कदाचन।",
                "karmaṇy-evādhikāras te mā phaleṣu kadācana",
                "You have a right to action alone, not to its fruits."
            )
        }
        
        // For other chapters, return placeholder content
        return (
            "कर्मण्येवाधिकारस्ते मा फलेषु कदाचन।",
            "karmaṇy-evādhikāras te mā phaleṣu kadācana",
            "You have a right to action alone, not to its fruits."
        )
    }
}

#Preview {
    SacredTextView()
}
