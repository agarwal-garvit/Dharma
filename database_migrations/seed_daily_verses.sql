-- Seed Daily Verses Data
-- This script populates the daily_verses table with 10 sample records
-- Starting from today's date (2025-10-27) and going forward

-- Insert 10 daily verses starting from 2025-10-27
INSERT INTO daily_verses (
    date,
    verse_id,
    chapter_index,
    verse_index,
    devanagari_text,
    iast_text,
    translation_en,
    keywords,
    themes,
    commentary_short,
    audio_url
) VALUES 
-- Day 1: October 27, 2025
(
    '2025-10-27',
    'daily-1-28',
    1,
    28,
    'दृष्ट्वेमं स्वजनं कृष्ण युयुत्सुं समुपस्थितम्।\nसीदन्ति मम गात्राणि मुखं च परिशुष्यति॥',
    'dṛṣṭvemaṁ sva-janaṁ kṛṣṇa yuyutsuṁ samupasthitam\nsīdanti mama gātrāṇi mukhaṁ ca pariśuṣyati',
    'Seeing my own kinsmen arrayed for battle, O Krishna, my limbs give way and my mouth is parched.',
    ARRAY['Moral Dilemma', 'Family', 'Duty', 'Compassion', 'Arjuna''s Despair'],
    ARRAY['Ethical Conflict', 'Dharma vs. Love', 'Inner Turmoil', 'Spiritual Crisis'],
    'This verse captures Arjuna''s profound moral crisis on the battlefield of Kurukshetra. Faced with the prospect of fighting his own relatives and teachers, Arjuna experiences physical and emotional breakdown, setting the stage for Krishna''s teachings on dharma and the nature of the self.',
    NULL
),

-- Day 2: October 28, 2025
(
    '2025-10-28',
    'daily-2-47',
    2,
    47,
    'कर्मण्येवाधिकारस्ते मा फलेषु कदाचन।\nमा कर्मफलहेतुर्भूर्मा ते सङ्गोऽस्त्वकर्मणि॥',
    'karmaṇy-evādhikāras te mā phaleṣu kadācana\nmā karma-phala-hetur bhūr mā te saṅgo ''stvakarmaṇi',
    'You have a right to perform your prescribed duty, but you are not entitled to the fruits of action. Never consider yourself the cause of the results of your activities, and never be attached to not doing your duty.',
    ARRAY['Karma', 'Duty', 'Detachment', 'Action'],
    ARRAY['Selfless Action', 'Dharma', 'Non-attachment'],
    'This verse teaches the essence of Karma Yoga - performing one''s duty without attachment to results. It emphasizes focusing on the action itself rather than its outcomes, which leads to inner peace and spiritual growth.',
    NULL
),

-- Day 3: October 29, 2025
(
    '2025-10-29',
    'daily-2-48',
    2,
    48,
    'योगस्थः कुरु कर्माणि सङ्गं त्यक्त्वा धनञ्जय।\nसिद्ध्यसिद्ध्योः समो भूत्वा समत्वं योग उच्यते॥',
    'yoga-sthaḥ kuru karmāṇi saṅgaṁ tyaktvā dhanañjaya\nsiddhy-asiddhyoḥ samo bhūtvā samatvaṁ yoga ucyate',
    'Perform your duty equipoised, O Arjuna, abandoning all attachment to success or failure. Such equanimity is called Yoga.',
    ARRAY['Yoga', 'Equanimity', 'Balance', 'Detachment'],
    ARRAY['Mental Peace', 'Steadiness', 'Inner Strength'],
    'True yoga is maintaining equanimity in all situations. This verse teaches us to remain balanced whether we succeed or fail, as this mental steadiness is the foundation of spiritual practice.',
    NULL
),

-- Day 4: October 30, 2025
(
    '2025-10-30',
    'daily-4-7',
    4,
    7,
    'यदा यदा हि धर्मस्य ग्लानिर्भवति भारत।\nअभ्युत्थानमधर्मस्य तदात्मानं सृजाम्यहम्॥',
    'yadā yadā hi dharmasya glānir bhavati bhārata\nabhyutthānam adharmasya tadātmānaṁ sṛjāmy aham',
    'Whenever there is a decline in righteousness and an increase in unrighteousness, O Arjuna, at that time I manifest Myself.',
    ARRAY['Dharma', 'Divine', 'Protection', 'Righteousness'],
    ARRAY['Divine Intervention', 'Justice', 'Cosmic Order'],
    'This verse assures us that the divine always protects dharma. Whenever evil becomes predominant, divine consciousness manifests to restore balance and guide humanity back to the righteous path.',
    NULL
),

-- Day 5: October 31, 2025
(
    '2025-10-31',
    'daily-2-62',
    2,
    62,
    'ध्यायतो विषयान्पुंसः सङ्गस्तेषूपजायते।\nसङ्गात्संजायते कामः कामात्क्रोधोऽभिजायते॥',
    'dhyāyato viṣayān puṁsaḥ saṅgas teṣūpajāyate\nsaṅgāt saṁjāyate kāmaḥ kāmāt krodho ''bhijāyate',
    'While contemplating the objects of the senses, a person develops attachment for them, and from such attachment lust develops, and from lust anger arises.',
    ARRAY['Desire', 'Attachment', 'Anger', 'Senses'],
    ARRAY['Mind Control', 'Detachment', 'Spiritual Discipline'],
    'This verse explains the chain reaction of negative emotions that begins with sense contemplation. It teaches us to be mindful of our thoughts and to practice detachment from sensory objects to maintain inner peace.',
    NULL
),

-- Day 6: November 1, 2025
(
    '2025-11-01',
    'daily-2-63',
    2,
    63,
    'क्रोधाद्भवति सम्मोहः सम्मोहात्स्मृतिविभ्रमः।\nस्मृतिभ्रंशाद्बुद्धिनाशो बुद्धिनाशात्प्रणश्यति॥',
    'krodhād bhavati sammohaḥ sammohāt smṛti-vibhramaḥ\nsmṛti-bhraṁśād buddhi-nāśo buddhi-nāśāt praṇaśyati',
    'From anger, complete delusion arises, and from delusion bewilderment of memory. When memory is bewildered, intelligence is lost, and when intelligence is lost, one falls down again into the material pool.',
    ARRAY['Anger', 'Delusion', 'Memory', 'Intelligence'],
    ARRAY['Mental Clarity', 'Self-Control', 'Spiritual Progress'],
    'This verse continues the chain reaction, showing how anger leads to complete mental confusion and spiritual downfall. It emphasizes the importance of maintaining mental clarity and self-control.',
    NULL
),

-- Day 7: November 2, 2025
(
    '2025-11-02',
    'daily-2-64',
    2,
    64,
    'रागद्वेषवियुक्तैस्तु विषयानिन्द्रियैश्चरन्।\nआत्मवश्यैर्विधेयात्मा प्रसादमधिगच्छति॥',
    'rāga-dveṣa-viyuktais tu viṣayān indriyair caran\nātma-vaśyair vidheyātmā prasādam adhigacchati',
    'But a person free from all attachment and aversion and able to control his senses through regulative principles of freedom can obtain the complete mercy of the Lord.',
    ARRAY['Detachment', 'Self-Control', 'Senses', 'Mercy'],
    ARRAY['Spiritual Freedom', 'Divine Grace', 'Self-Mastery'],
    'This verse offers the solution to the previous problems. By practicing detachment and self-control, one can attain divine grace and spiritual freedom.',
    NULL
),

-- Day 8: November 3, 2025
(
    '2025-11-03',
    'daily-2-70',
    2,
    70,
    'आपूर्यमाणमचलप्रतिष्ठं\nसमुद्रमापः प्रविशन्ति यद्वत्।\nतद्वत्कामा यं प्रविशन्ति सर्वे\nस शान्तिमाप्नोति न कामकामी॥',
    'āpūryamāṇam acala-pratiṣṭhaṁ\nsamudram āpaḥ praviśanti yadvat\ntadvat kāmā yaṁ praviśanti sarve\nsa śāntim āpnoti na kāma-kāmī',
    'A person who is not disturbed by the incessant flow of desires—that enter like rivers into the ocean, which is ever being filled but is always still—can alone achieve peace, and not the person who strives to satisfy such desires.',
    ARRAY['Desires', 'Peace', 'Ocean', 'Stillness'],
    ARRAY['Inner Peace', 'Desire Management', 'Spiritual Equanimity'],
    'This beautiful metaphor compares the mind to an ocean that remains calm despite constant inflow of desires. It teaches us that true peace comes from maintaining inner stillness, not from fulfilling every desire.',
    NULL
),

-- Day 9: November 4, 2025
(
    '2025-11-04',
    'daily-2-71',
    2,
    71,
    'विहाय कामान्यः सर्वान्पुमांश्चरति निःस्पृहः।\nनिर्ममो निरहंकारः स शान्तिमधिगच्छति॥',
    'vihāya kāmān yaḥ sarvān pumāṁś carati niḥspṛhaḥ\nnirmamo nirahaṅkāraḥ sa śāntim adhigacchati',
    'A person who has given up all desires for sense gratification, who lives free from desires, who has given up all sense of proprietorship and is devoid of false ego—he alone can attain real peace.',
    ARRAY['Desires', 'Ego', 'Peace', 'Detachment'],
    ARRAY['Self-Realization', 'True Peace', 'Spiritual Liberation'],
    'This verse describes the characteristics of a truly peaceful person: free from desires, ego, and possessiveness. Such a person has transcended material attachments and achieved genuine spiritual peace.',
    NULL
),

-- Day 10: November 5, 2025
(
    '2025-11-05',
    'daily-2-72',
    2,
    72,
    'एषा ब्राह्मी स्थितिः पार्थ नैनां प्राप्य विमुह्यति।\nस्थित्वास्यामन्तकालेऽपि ब्रह्मनिर्वाणमृच्छति॥',
    'eṣā brāhmī sthitiḥ pārtha naināṁ prāpya vimuhyati\nsthitvāsyām anta-kāle ''pi brahma-nirvāṇam ṛcchati',
    'That is the way of the spiritual and godly life, after attaining which a person is not bewildered. Being so situated, even at the hour of death, one can enter into the kingdom of God.',
    ARRAY['Spiritual Life', 'Divine', 'Death', 'Liberation'],
    ARRAY['Divine Consciousness', 'Spiritual Liberation', 'Eternal Peace'],
    'This verse concludes the teaching on the spiritual way of life. It assures us that by following these principles, we can maintain divine consciousness even at the moment of death and achieve ultimate liberation.',
    NULL
);

-- Verify the data was inserted correctly
SELECT 
    date,
    verse_id,
    chapter_index,
    verse_index,
    LEFT(translation_en, 50) || '...' as translation_preview
FROM daily_verses 
ORDER BY date;
