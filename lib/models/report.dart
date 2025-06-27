import 'package:cloud_firestore/cloud_firestore.dart';

class ReportImage {
  final String url;
  final String type;
  final DateTime timestamp;

  ReportImage({
    required this.url,
    required this.type,
    required this.timestamp,
  });

  factory ReportImage.fromMap(Map<String, dynamic> map) {
    return ReportImage(
      url: map['url'] as String,
      type: map['type'] as String,
      timestamp: (map['timestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'url': url,
      'type': type,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}

class Report {
  final String id;
  final String userId;
  final String technicianName;
  final DateTime inspectionDate;
  final String location;
  final String pipeDiameter;
  final String wallThickness;
  final String method;
  final String findings;
  final String correctiveActions;
  final String? additionalNotes;
  final List<String> imageUrls; // Keep for backward compatibility
  final List<ReportImage> images; // New structured images
  final DateTime createdAt;
  final DateTime updatedAt;

  // DIG Information fields
  final String? digNumber;
  final String? gformNumber;
  final String? clientWoNumber;
  final String? integritySpecialistsNumber;
  final String? rfsNumber;
  final DateTime? excavationDate;
  final DateTime? assessmentDate;
  final DateTime? reportDate;
  final DateTime? backfillDate;
  final String? reasonForDig;
  final String? state;
  final String? county;
  final String? district;
  final String? section;
  final String? range;
  final String? tws;
  final String? mp;
  final String? projectName;
  final String? lineNumber;
  final String? digSite;
  final String? productFlow;
  final String? comments;

  // ILI Tool Information fields
  final String? iliToolProvider;
  final String? toolsRan;
  final DateTime? toolRunDate;
  final String? pigLauncher;
  final String? pigReceiver;
  final String? toolFlow;
  final String? totalMiles;
  final bool? liveLine;
  final String? iliComments;

  // Pipe Static Data fields
  final String? nominalWallThickness;
  final String? pipeStaticDiameter;
  final String? longseamWeldType;
  final String? girthWeldType;
  final String? smys;
  final String? maop;
  final String? safetyFactor;
  final String? operatingPsi;
  final String? pipeManufacturer;
  final DateTime? installDate;
  final String? product;
  final String? pipeStaticComments;

  // Pipe Evaluation fields
  final String? cpSystem;
  final String? soilResistivity;
  final String? testType;
  final String? coatingType;
  final String? overallCondition;
  final String? conditionAtAnomaly;
  final String? percentBonded;
  final String? percentDisbonded;
  final String? percentBarePipe;
  final bool? evidenceOfSoilBodyStress;
  final bool? deposits;
  final String? locationOfDeposits;
  final String? descriptionOfDeposits;
  final String? pipeToSoilDC;
  final String? pipeToSoilAC;
  final String? phOnPipe;
  final String? phAtAnomaly;
  final String? phOfSoil;
  final bool? pipeBend;
  final String? degreeOfBend;
  final String? absEsOfBend;
  final String? pipeSlope;
  final String? pipeEvaluationComments;

  // Environment fields
  final String? terrainAtDigSite;
  final String? soilTypeAtPipeLevel;
  final String? soilTypeAtSixOClock;
  final String? depthOfCover;
  final String? organicDepth;
  final String? usage;
  final String? pipeTemperature;
  final String? ambientTemperature;
  final String? weatherConditions;
  final String? drainage;
  final String? environmentComments;

  // Joint and Girth Weld Details fields
  final String? startOfDigAbsEs;
  final String? endOfDigAbsEs;
  final String? lengthOfPipeExposed;
  final String? lengthOfPipeAssessed;

  // Defect Evaluation fields
  final bool? defectNoted;
  final String? typeOfDefect;
  final bool? burstPressureAnalysis;
  final bool? methodB31G;
  final bool? methodB31GModified;
  final bool? methodKapa;
  final bool? methodRstreng;
  final bool? wetMpiPerformed;
  final String? startOfWetMpi;
  final String? endOfWetMpi;
  final String? lengthOfWetMpi;
  final String? defectEvaluationComments;

  // Summary fields
  final String? startOfRecoatAbsEs;
  final String? endOfRecoatAbsEs;
  final String? totalLengthOfRecoat;
  final String? recoatManufacturer;
  final String? recoatProduct;
  final String? recoatType;

  Report({
    required this.id,
    required this.userId,
    required this.technicianName,
    required this.inspectionDate,
    required this.location,
    required this.pipeDiameter,
    required this.wallThickness,
    required this.method,
    required this.findings,
    required this.correctiveActions,
    this.additionalNotes,
    this.imageUrls = const [],
    this.images = const [],
    required this.createdAt,
    required this.updatedAt,
    // DIG Information fields
    this.digNumber,
    this.gformNumber,
    this.clientWoNumber,
    this.integritySpecialistsNumber,
    this.rfsNumber,
    this.excavationDate,
    this.assessmentDate,
    this.reportDate,
    this.backfillDate,
    this.reasonForDig,
    this.state,
    this.county,
    this.district,
    this.section,
    this.range,
    this.tws,
    this.mp,
    this.projectName,
    this.lineNumber,
    this.digSite,
    this.productFlow,
    this.comments,
    // ILI Tool Information fields
    this.iliToolProvider,
    this.toolsRan,
    this.toolRunDate,
    this.pigLauncher,
    this.pigReceiver,
    this.toolFlow,
    this.totalMiles,
    this.liveLine,
    this.iliComments,
    // Pipe Static Data fields
    this.nominalWallThickness,
    this.pipeStaticDiameter,
    this.longseamWeldType,
    this.girthWeldType,
    this.smys,
    this.maop,
    this.safetyFactor,
    this.operatingPsi,
    this.pipeManufacturer,
    this.installDate,
    this.product,
    this.pipeStaticComments,
    // Pipe Evaluation fields
    this.cpSystem,
    this.soilResistivity,
    this.testType,
    this.coatingType,
    this.overallCondition,
    this.conditionAtAnomaly,
    this.percentBonded,
    this.percentDisbonded,
    this.percentBarePipe,
    this.evidenceOfSoilBodyStress,
    this.deposits,
    this.locationOfDeposits,
    this.descriptionOfDeposits,
    this.pipeToSoilDC,
    this.pipeToSoilAC,
    this.phOnPipe,
    this.phAtAnomaly,
    this.phOfSoil,
    this.pipeBend,
    this.degreeOfBend,
    this.absEsOfBend,
    this.pipeSlope,
    this.pipeEvaluationComments,
    // Environment fields
    this.terrainAtDigSite,
    this.soilTypeAtPipeLevel,
    this.soilTypeAtSixOClock,
    this.depthOfCover,
    this.organicDepth,
    this.usage,
    this.pipeTemperature,
    this.ambientTemperature,
    this.weatherConditions,
    this.drainage,
    this.environmentComments,
    // Joint and Girth Weld Details fields
    this.startOfDigAbsEs,
    this.endOfDigAbsEs,
    this.lengthOfPipeExposed,
    this.lengthOfPipeAssessed,
    // Defect Evaluation fields
    this.defectNoted,
    this.typeOfDefect,
    this.burstPressureAnalysis,
    this.methodB31G,
    this.methodB31GModified,
    this.methodKapa,
    this.methodRstreng,
    this.wetMpiPerformed,
    this.startOfWetMpi,
    this.endOfWetMpi,
    this.lengthOfWetMpi,
    this.defectEvaluationComments,
    // Summary fields
    this.startOfRecoatAbsEs,
    this.endOfRecoatAbsEs,
    this.totalLengthOfRecoat,
    this.recoatManufacturer,
    this.recoatProduct,
    this.recoatType,
  });

  factory Report.fromMap(Map<String, dynamic> map) {
    return Report(
      id: map['id'] as String,
      userId: map['userId'] as String,
      technicianName: map['technicianName'] as String,
      inspectionDate: (map['inspectionDate'] as Timestamp).toDate(),
      location: map['location'] as String,
      pipeDiameter: map['pipeDiameter'] as String,
      wallThickness: map['wallThickness'] as String,
      method: map['method'] as String,
      findings: map['findings'] as String,
      correctiveActions: map['correctiveActions'] as String,
      additionalNotes: map['additionalNotes'] as String?,
      imageUrls: List<String>.from(map['imageUrls'] ?? []),
      images: (map['images'] as List<dynamic>?)
              ?.map((item) => ReportImage.fromMap(item as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
      // DIG Information fields
      digNumber: map['digNumber'] as String?,
      gformNumber: map['gformNumber'] as String?,
      clientWoNumber: map['clientWoNumber'] as String?,
      integritySpecialistsNumber: map['integritySpecialistsNumber'] as String?,
      rfsNumber: map['rfsNumber'] as String?,
      excavationDate: map['excavationDate'] != null
          ? (map['excavationDate'] as Timestamp).toDate()
          : null,
      assessmentDate: map['assessmentDate'] != null
          ? (map['assessmentDate'] as Timestamp).toDate()
          : null,
      reportDate: map['reportDate'] != null
          ? (map['reportDate'] as Timestamp).toDate()
          : null,
      backfillDate: map['backfillDate'] != null
          ? (map['backfillDate'] as Timestamp).toDate()
          : null,
      reasonForDig: map['reasonForDig'] as String?,
      state: map['state'] as String?,
      county: map['county'] as String?,
      district: map['district'] as String?,
      section: map['section'] as String?,
      range: map['range'] as String?,
      tws: map['tws'] as String?,
      mp: map['mp'] as String?,
      projectName: map['projectName'] as String?,
      lineNumber: map['lineNumber'] as String?,
      digSite: map['digSite'] as String?,
      productFlow: map['productFlow'] as String?,
      comments: map['comments'] as String?,
      // ILI Tool Information fields
      iliToolProvider: map['iliToolProvider'] as String?,
      toolsRan: map['toolsRan'] as String?,
      toolRunDate: map['toolRunDate'] != null
          ? (map['toolRunDate'] as Timestamp).toDate()
          : null,
      pigLauncher: map['pigLauncher'] as String?,
      pigReceiver: map['pigReceiver'] as String?,
      toolFlow: map['toolFlow'] as String?,
      totalMiles: map['totalMiles'] as String?,
      liveLine: map['liveLine'] as bool?,
      iliComments: map['iliComments'] as String?,
      // Pipe Static Data fields
      nominalWallThickness: map['nominalWallThickness'] as String?,
      pipeStaticDiameter: map['pipeStaticDiameter'] as String?,
      longseamWeldType: map['longseamWeldType'] as String?,
      girthWeldType: map['girthWeldType'] as String?,
      smys: map['smys'] as String?,
      maop: map['maop'] as String?,
      safetyFactor: map['safetyFactor'] as String?,
      operatingPsi: map['operatingPsi'] as String?,
      pipeManufacturer: map['pipeManufacturer'] as String?,
      installDate: map['installDate'] != null
          ? (map['installDate'] as Timestamp).toDate()
          : null,
      product: map['product'] as String?,
      pipeStaticComments: map['pipeStaticComments'] as String?,
      // Pipe Evaluation fields
      cpSystem: map['cpSystem'] as String?,
      soilResistivity: map['soilResistivity'] as String?,
      testType: map['testType'] as String?,
      coatingType: map['coatingType'] as String?,
      overallCondition: map['overallCondition'] as String?,
      conditionAtAnomaly: map['conditionAtAnomaly'] as String?,
      percentBonded: map['percentBonded'] as String?,
      percentDisbonded: map['percentDisbonded'] as String?,
      percentBarePipe: map['percentBarePipe'] as String?,
      evidenceOfSoilBodyStress: map['evidenceOfSoilBodyStress'] as bool?,
      deposits: map['deposits'] as bool?,
      locationOfDeposits: map['locationOfDeposits'] as String?,
      descriptionOfDeposits: map['descriptionOfDeposits'] as String?,
      pipeToSoilDC: map['pipeToSoilDC'] as String?,
      pipeToSoilAC: map['pipeToSoilAC'] as String?,
      phOnPipe: map['phOnPipe'] as String?,
      phAtAnomaly: map['phAtAnomaly'] as String?,
      phOfSoil: map['phOfSoil'] as String?,
      pipeBend: map['pipeBend'] as bool?,
      degreeOfBend: map['degreeOfBend'] as String?,
      absEsOfBend: map['absEsOfBend'] as String?,
      pipeSlope: map['pipeSlope'] as String?,
      pipeEvaluationComments: map['pipeEvaluationComments'] as String?,
      // Environment fields
      terrainAtDigSite: map['terrainAtDigSite'] as String?,
      soilTypeAtPipeLevel: map['soilTypeAtPipeLevel'] as String?,
      soilTypeAtSixOClock: map['soilTypeAtSixOClock'] as String?,
      depthOfCover: map['depthOfCover'] as String?,
      organicDepth: map['organicDepth'] as String?,
      usage: map['usage'] as String?,
      pipeTemperature: map['pipeTemperature'] as String?,
      ambientTemperature: map['ambientTemperature'] as String?,
      weatherConditions: map['weatherConditions'] as String?,
      drainage: map['drainage'] as String?,
      environmentComments: map['environmentComments'] as String?,
      // Joint and Girth Weld Details fields
      startOfDigAbsEs: map['startOfDigAbsEs'] as String?,
      endOfDigAbsEs: map['endOfDigAbsEs'] as String?,
      lengthOfPipeExposed: map['lengthOfPipeExposed'] as String?,
      lengthOfPipeAssessed: map['lengthOfPipeAssessed'] as String?,
      // Defect Evaluation fields
      defectNoted: map['defectNoted'] as bool?,
      typeOfDefect: map['typeOfDefect'] as String?,
      burstPressureAnalysis: map['burstPressureAnalysis'] as bool?,
      methodB31G: map['methodB31G'] as bool?,
      methodB31GModified: map['methodB31GModified'] as bool?,
      methodKapa: map['methodKapa'] as bool?,
      methodRstreng: map['methodRstreng'] as bool?,
      wetMpiPerformed: map['wetMpiPerformed'] as bool?,
      startOfWetMpi: map['startOfWetMpi'] as String?,
      endOfWetMpi: map['endOfWetMpi'] as String?,
      lengthOfWetMpi: map['lengthOfWetMpi'] as String?,
      defectEvaluationComments: map['defectEvaluationComments'] as String?,
      // Summary fields
      startOfRecoatAbsEs: map['startOfRecoatAbsEs'] as String?,
      endOfRecoatAbsEs: map['endOfRecoatAbsEs'] as String?,
      totalLengthOfRecoat: map['totalLengthOfRecoat'] as String?,
      recoatManufacturer: map['recoatManufacturer'] as String?,
      recoatProduct: map['recoatProduct'] as String?,
      recoatType: map['recoatType'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'technicianName': technicianName,
      'inspectionDate': Timestamp.fromDate(inspectionDate),
      'location': location,
      'pipeDiameter': pipeDiameter,
      'wallThickness': wallThickness,
      'method': method,
      'findings': findings,
      'correctiveActions': correctiveActions,
      'additionalNotes': additionalNotes,
      'imageUrls': imageUrls,
      'images': images.map((image) => image.toMap()).toList(),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      // DIG Information fields
      'digNumber': digNumber,
      'gformNumber': gformNumber,
      'clientWoNumber': clientWoNumber,
      'integritySpecialistsNumber': integritySpecialistsNumber,
      'rfsNumber': rfsNumber,
      'excavationDate':
          excavationDate != null ? Timestamp.fromDate(excavationDate!) : null,
      'assessmentDate':
          assessmentDate != null ? Timestamp.fromDate(assessmentDate!) : null,
      'reportDate': reportDate != null ? Timestamp.fromDate(reportDate!) : null,
      'backfillDate':
          backfillDate != null ? Timestamp.fromDate(backfillDate!) : null,
      'reasonForDig': reasonForDig,
      'state': state,
      'county': county,
      'district': district,
      'section': section,
      'range': range,
      'tws': tws,
      'mp': mp,
      'projectName': projectName,
      'lineNumber': lineNumber,
      'digSite': digSite,
      'productFlow': productFlow,
      'comments': comments,
      // ILI Tool Information fields
      'iliToolProvider': iliToolProvider,
      'toolsRan': toolsRan,
      'toolRunDate':
          toolRunDate != null ? Timestamp.fromDate(toolRunDate!) : null,
      'pigLauncher': pigLauncher,
      'pigReceiver': pigReceiver,
      'toolFlow': toolFlow,
      'totalMiles': totalMiles,
      'liveLine': liveLine,
      'iliComments': iliComments,
      // Pipe Static Data fields
      'nominalWallThickness': nominalWallThickness,
      'pipeStaticDiameter': pipeStaticDiameter,
      'longseamWeldType': longseamWeldType,
      'girthWeldType': girthWeldType,
      'smys': smys,
      'maop': maop,
      'safetyFactor': safetyFactor,
      'operatingPsi': operatingPsi,
      'pipeManufacturer': pipeManufacturer,
      'installDate':
          installDate != null ? Timestamp.fromDate(installDate!) : null,
      'product': product,
      'pipeStaticComments': pipeStaticComments,
      // Pipe Evaluation fields
      'cpSystem': cpSystem,
      'soilResistivity': soilResistivity,
      'testType': testType,
      'coatingType': coatingType,
      'overallCondition': overallCondition,
      'conditionAtAnomaly': conditionAtAnomaly,
      'percentBonded': percentBonded,
      'percentDisbonded': percentDisbonded,
      'percentBarePipe': percentBarePipe,
      'evidenceOfSoilBodyStress': evidenceOfSoilBodyStress,
      'deposits': deposits,
      'locationOfDeposits': locationOfDeposits,
      'descriptionOfDeposits': descriptionOfDeposits,
      'pipeToSoilDC': pipeToSoilDC,
      'pipeToSoilAC': pipeToSoilAC,
      'phOnPipe': phOnPipe,
      'phAtAnomaly': phAtAnomaly,
      'phOfSoil': phOfSoil,
      'pipeBend': pipeBend,
      'degreeOfBend': degreeOfBend,
      'absEsOfBend': absEsOfBend,
      'pipeSlope': pipeSlope,
      'pipeEvaluationComments': pipeEvaluationComments,
      // Environment fields
      'terrainAtDigSite': terrainAtDigSite,
      'soilTypeAtPipeLevel': soilTypeAtPipeLevel,
      'soilTypeAtSixOClock': soilTypeAtSixOClock,
      'depthOfCover': depthOfCover,
      'organicDepth': organicDepth,
      'usage': usage,
      'pipeTemperature': pipeTemperature,
      'ambientTemperature': ambientTemperature,
      'weatherConditions': weatherConditions,
      'drainage': drainage,
      'environmentComments': environmentComments,
      // Joint and Girth Weld Details fields
      'startOfDigAbsEs': startOfDigAbsEs,
      'endOfDigAbsEs': endOfDigAbsEs,
      'lengthOfPipeExposed': lengthOfPipeExposed,
      'lengthOfPipeAssessed': lengthOfPipeAssessed,
      // Defect Evaluation fields
      'defectNoted': defectNoted,
      'typeOfDefect': typeOfDefect,
      'burstPressureAnalysis': burstPressureAnalysis,
      'methodB31G': methodB31G,
      'methodB31GModified': methodB31GModified,
      'methodKapa': methodKapa,
      'methodRstreng': methodRstreng,
      'wetMpiPerformed': wetMpiPerformed,
      'startOfWetMpi': startOfWetMpi,
      'endOfWetMpi': endOfWetMpi,
      'lengthOfWetMpi': lengthOfWetMpi,
      'defectEvaluationComments': defectEvaluationComments,
      // Summary fields
      'startOfRecoatAbsEs': startOfRecoatAbsEs,
      'endOfRecoatAbsEs': endOfRecoatAbsEs,
      'totalLengthOfRecoat': totalLengthOfRecoat,
      'recoatManufacturer': recoatManufacturer,
      'recoatProduct': recoatProduct,
      'recoatType': recoatType,
    };
  }

  // Helper method to get images sorted by type priority
  List<ReportImage> get sortedImages {
    final typeOrder = [
      'upstream',
      'downstream',
      'soil_strate',
      'coating_overview'
    ];
    final sorted = List<ReportImage>.from(images);

    sorted.sort((a, b) {
      final aIndex = typeOrder.indexOf(a.type);
      final bIndex = typeOrder.indexOf(b.type);

      // If both types are in the priority list, sort by priority
      if (aIndex != -1 && bIndex != -1) {
        return aIndex.compareTo(bIndex);
      }

      // If only one is in the priority list, prioritize it
      if (aIndex != -1) return -1;
      if (bIndex != -1) return 1;

      // If neither is in the priority list, sort by timestamp
      return a.timestamp.compareTo(b.timestamp);
    });

    return sorted;
  }
}
