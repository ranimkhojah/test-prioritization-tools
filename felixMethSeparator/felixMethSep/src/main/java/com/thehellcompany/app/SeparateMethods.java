package com.thehellcompany.app;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.StringReader;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Optional;
import java.util.Scanner;
import java.util.stream.Collectors;

import com.github.javaparser.StaticJavaParser;
import com.github.javaparser.ast.CompilationUnit;
import com.github.javaparser.ast.Node;
import com.github.javaparser.ast.NodeList;
import com.github.javaparser.ast.PackageDeclaration;
import com.github.javaparser.ast.body.BodyDeclaration;
import com.github.javaparser.ast.body.ClassOrInterfaceDeclaration;
import com.github.javaparser.ast.body.MethodDeclaration;
import com.github.javaparser.ast.body.TypeDeclaration;
import com.github.javaparser.ast.expr.ObjectCreationExpr;
import com.github.javaparser.ast.type.ClassOrInterfaceType;
import com.github.javaparser.ast.visitor.GenericVisitor;
import com.github.javaparser.ast.visitor.VoidVisitor;
import com.github.javaparser.ast.visitor.VoidVisitorWithDefaults;

import org.apache.maven.plugins.surefire.report.ReportTestSuite;
import org.apache.maven.plugins.surefire.report.SurefireReportParser;
import org.apache.maven.reporting.MavenReportException;
// import org.pitest.classpath.CodeSource;
// import org.pitest.mutationtest.build.DefaultGrouper;
// import org.pitest.mutationtest.build.MutationGrouper;
// import org.pitest.mutationtest.build.MutationGrouperFactory;

public class SeparateMethods {

	private static final String SUREFIRE_DIR = "target/surefire-reports";

	private static final String TEST_CODE_DIR = "target/pit-reports/code";

	private Map<String, CompilationUnit> methodUnit = new HashMap<>();

	private static String versionTestPathForParent;

	private static int totalParentCounter = 0;
	private static int versionParentCounter = 0;
	private static int grandparentCounter = 0;

	private static ArrayList versionParentCountList = new ArrayList<>();
	private static ArrayList versionGrandParentCountList = new ArrayList<>();

	public static void main(String[] args) throws FileNotFoundException {

		// Collection<String> classAndMethodNames =
		// extractTestInfoFromSurefireReports();

		File methlistFolder = new File(SUREFIRE_DIR);
		File[] listOfMethlistFiles = methlistFolder.listFiles();
		System.out.println(listOfMethlistFiles);
		for (int i = 0; i < listOfMethlistFiles.length; i++) {
			SeparateMethods separateMethods = new SeparateMethods();

			if (listOfMethlistFiles[i].isFile()) {
				String currentMethListFilename = listOfMethlistFiles[i].getName();
				System.out.println("File: " + currentMethListFilename);

				// get current version (and project)
				String[] splitFilename = currentMethListFilename.split("_");
				String currentVersion = splitFilename[0];
				System.out.println("Version: " + currentVersion);

				String versionTestPath = currentVersion + "/src/test/";
				Path checkVersionPath = Paths.get("target/projects_to_separate/" + currentVersion + "/src/test/java");
				Path checkGsonVersionPath = Paths.get("target/projects_to_separate/" + currentVersion + "/gson/src/test/java");
				// use it to know where to get the tests later on
				if (Files.exists(checkVersionPath)) {
					versionTestPath = currentVersion + "/src/test/java/";
					System.out.println("src/test/java exists! ");
				}
				if (Files.exists(checkGsonVersionPath)) {
					versionTestPath = currentVersion + "/gson/src/test/java/";
					System.out.println("its gson. hello.");
				}

				System.out.println(versionTestPath);
				versionTestPathForParent = versionTestPath;

				// System.out.println("src/test/java/" + versionTestPath + "className" + ".java");

				// reads methods in the current file
				Scanner scanner = new Scanner(new File(SUREFIRE_DIR + "/" + currentMethListFilename));
				List<String> classAndMethodNames = new ArrayList<String>();
				int numOfMethods = 0;

				while (scanner.hasNextLine()) {
					String currentLine = scanner.nextLine();
					if (currentLine.contains(".enum.")) {
						System.out.println("method folder contains enum keyword, ignoring - " + currentLine);
					}
					else {
						// System.out.println(currentLine);
						classAndMethodNames.add(currentLine);
						numOfMethods++;
					}
				}
				scanner.close();
				System.out.println(numOfMethods);
				// System.out.println( "Class and method names: " + classAndMethodNames );
				
				// Separate methods into files
				separateMethods.initializeCompilationUnitsForAllClasses(classAndMethodNames, versionTestPath);
				separateMethods.extractsingledOutMethodFilesFor(classAndMethodNames, currentVersion);

				


			} else if (listOfMethlistFiles[i].isDirectory()) {
				System.out.println("Directory: " + listOfMethlistFiles[i].getName());
			}
			versionParentCountList.add(versionParentCounter);
			versionParentCounter = 0;
		}

		for (int i = 0; i < versionParentCountList.size(); i++) {
			System.out.println(versionParentCountList.get(i));
		}
		System.out.println("No. of Total Inherited Tests: " + totalParentCounter);
		// separateMethods.getMethodListFilenames();
		// separateMethods.initializeCompilationUnitsForAllClasses(classAndMethodNames);
		// separateMethods.extractsingledOutMethodFilesFor(classAndMethodNames);
      
	}
	

   private void initializeCompilationUnitsForAllClasses(Collection<String> classAndMethodNames, String versionTestPath) {
		classAndMethodNames.stream().forEach(name -> {

			int delimiter = name.lastIndexOf(".");
			String className = name.substring(0, delimiter);
			String methodName = name.substring(delimiter + 1);

			try {
				initializeCompilationUnitFor(versionTestPath, className, methodName);
			} catch (IOException e) {
				e.printStackTrace();
			}
		});
	}

	private void initializeCompilationUnitFor(String versionTestPath, String className, String methodName) throws IOException {
		if (methodUnit.containsKey(className)) {
			CompilationUnit existingUnit = methodUnit.get(className);
			methodUnit.put(className + "." + methodName, existingUnit);
			return;
		}

		String classPath = className.replace('.', '/');
		// System.out.println("Class Location: " + "src/test/java/" + versionTestPath + classPath + ".java");
		Path classLocation = Paths.get("target/projects_to_separate/" + versionTestPath + classPath + ".java");
		

		CompilationUnit unit = StaticJavaParser.parse(classLocation);

		methodUnit.put(className + "." + methodName, unit);
		methodUnit.put(className, unit);
	}

	private void extractsingledOutMethodFilesFor(Collection<String> classNames, String version) {

		new File(TEST_CODE_DIR + "/" + version).mkdir(); // create folder to store to

		classNames.stream().forEach(name -> {
			// int ignoredTests = 0;

			try {
				int delimiter = name.lastIndexOf(".");
				String className = name.substring(0, delimiter);
				String methodName = name.substring(delimiter + 1);

				// System.out.println(className);
				// System.out.println(methodName);

				if (methodName.contains("OBJECT_READER") || methodName.contains("STRING_READER") || methodName.contains("[")) {
					System.out.println("Random crap incoming  " + methodName);
				// 	String[] splitname = methodName.split("\\[");
				// 	methodName = splitname[0];
				// 	System.out.println("Actual name: " + methodName);
				}
				// System.out.println("wtf is this    -- " + methodName);

				String code = retrieveCodeFor(className, methodName);
				if (code == "Nonexistent") {
					
					// ignoredTests++;
					// System.out.println("\"" + methodName + "\" does not exist in type \"" + className + "\"! Looking in parent.");
					String parentCode = retrieveParentCodeFor(className, methodName);
					// System.out.println("Total Ignored: " + ignoredTests);
					
					if (parentCode == "Still Nonexistent") {
						System.out.println("\"" + methodName + "\" still does not exist in type \"" + className + "'s parent" + "\"! Ignored.");
					}
					else if (parentCode.contains("Defects4J: flaky method")) {
						System.out.println("The method \"" + methodName + "\", \"" + className + "\" is flaky! removing comments.");
						String commentlessCode = removeComments(parentCode);
						
						Files.write(Paths.get(TEST_CODE_DIR + "/" + version + "/" + name + ".txt"), commentlessCode.getBytes());
					}
					else {
						versionParentCounter++;
						totalParentCounter++;
						Files.write(Paths.get(TEST_CODE_DIR + "/" + version + "/" + name + ".txt"), parentCode.getBytes());
					}
				}
				else if (code.contains("Defects4J: flaky method")) {
					System.out.println("The method \"" + methodName + "\", \"" + className + "\" is flaky! removing comments.");
					String commentlessCode = removeComments(code);
					
					Files.write(Paths.get(TEST_CODE_DIR + "/" + version + "/" + name + ".txt"), commentlessCode.getBytes());
				}
				else {
					// System.out.println("writing to : " + TEST_CODE_DIR + "/" + version + "/" + name + ".txt");
					Files.write(Paths.get(TEST_CODE_DIR + "/" + version + "/" + name + ".txt"), code.getBytes());
				}
				
			} catch (IOException e) {
				e.printStackTrace();
			}
		});

	}
	
	private String removeComments(String method) throws IOException {
		BufferedReader bufReader = new BufferedReader(new StringReader(method));
		String currentline = null;
		String revisedCode = "";
		while ( (currentline = bufReader.readLine()) != null) {
			if (currentline.contains("//")) {
				// System.out.println("Replacing " + currentline);
				currentline = "";
				// System.out.println("After " + currentline);
			}
			else {
				// System.out.println("Concating: " + currentline);
				revisedCode = revisedCode.concat(currentline + "\n");
			}
		}
		return revisedCode;
  }

	private CompilationUnit findParentCompUnit(String className, String methodName, String parentClassName) throws IOException {
		// System.out.println(className);
		String[] splitClassName = className.split("\\.");
		// System.out.println("Split Names: " + Arrays.toString(splitClassName));

		String parentClassTestPath = "";
		CompilationUnit parentTestUnit = null;

		// manually find location of inherited class
		for (int i = splitClassName.length - 1; i > 0; i-- ) {
			parentClassTestPath = "";
			for (int a = 0; a < i; a++) {
				parentClassTestPath = parentClassTestPath + splitClassName[a] + ".";
				// System.out.println(parentClassTestPath);
			}
			parentClassTestPath = parentClassTestPath + parentClassName;

			// copied from initializecompilationunits
			if (methodUnit.containsKey(parentClassTestPath)) {
				CompilationUnit existingUnit = methodUnit.get(parentClassTestPath);
				methodUnit.put(parentClassTestPath + "." + methodName, existingUnit);
				// System.out.println("put method in methodunit");
			}

			String classPath = parentClassTestPath.replace('.', '/');
			// System.out.println("Class Location: " + "src/test/java/" + versionTestPath + classPath + ".java");
			
			Path classLocation = Paths.get("target/projects_to_separate/" + versionTestPathForParent + classPath + ".java");
			// System.out.println(classLocation);

			if (Files.exists(classLocation)) {
				// System.out.println("Class Location exists ->  " + classLocation + ", ::   " + methodName);
				parentTestUnit = StaticJavaParser.parse(classLocation);
				// need to put path into methodunit or something first
				methodUnit.put(parentClassTestPath + "." + methodName, parentTestUnit);
				methodUnit.put(parentClassTestPath, parentTestUnit);
	
				// combine classpath and method here
				parentTestUnit = methodUnit.get(parentClassTestPath + "." + methodName);
				// System.out.println(parentTestUnit);
				if (parentTestUnit == null) {
					System.out.println(parentClassTestPath +  " does not exist.");
				}
				
				if (parentTestUnit != null) {
					// System.out.println("Found! -- ");
					break;
				}
			}
		}
		return parentTestUnit;
	}

	private String getParentClassPath(String className, String methodName, String parentClassName) throws IOException {
		String[] splitClassName = className.split("\\.");
		// System.out.println("Split Names: " + Arrays.toString(splitClassName));

		String parentClassTestPath = "";
		String classPath = "";
		// manually find location of inherited class
		for (int i = splitClassName.length - 1; i > 0; i-- ) {
			parentClassTestPath = "";
			for (int a = 0; a < i; a++) {
				parentClassTestPath = parentClassTestPath + splitClassName[a] + ".";
				// System.out.println(parentClassTestPath);
			}
			parentClassTestPath = parentClassTestPath + parentClassName;

			// copied from initializecompilationunits
			if (methodUnit.containsKey(parentClassTestPath)) {
				CompilationUnit existingUnit = methodUnit.get(parentClassTestPath);
				methodUnit.put(parentClassTestPath + "." + methodName, existingUnit);
				// System.out.println("put method in methodunit");
			}

			classPath = parentClassTestPath.replace('.', '/');
			// System.out.println("Class Location: " + "src/test/java/" + versionTestPath + classPath + ".java");
			
			Path classLocation = Paths.get("target/projects_to_separate/" + versionTestPathForParent + classPath + ".java");
			// System.out.println(classLocation);

			if (Files.exists(classLocation)) {
				// at this point path should already be in methodunit
				System.out.println("Parent Class Location exists ->  " + classLocation + ", ::   " + methodName);
				// parentTestUnit = StaticJavaParser.parse(classLocation);
				// // need to put path into methodunit or something first
				// methodUnit.put(parentClassTestPath + "." + methodName, parentTestUnit);
				// methodUnit.put(parentClassTestPath, parentTestUnit);
				// System.out.println("Exitting search");
				break;
			}
			// else {
			// 	// System.out.println("Sumthin wrong");
			// }
		}
		return parentClassTestPath;
	}

  private String retrieveParentCodeFor(String className, String methodName) throws IOException {
	CompilationUnit unit = methodUnit.get(className + "." + methodName);

	// get name of parent class 1 level above
	ClassOrInterfaceDeclaration type = unit.getType(0).asClassOrInterfaceDeclaration(); 
	NodeList<ClassOrInterfaceType> extendedTypes = type.getExtendedTypes();
	// System.out.println(extendedTypes);
	ClassOrInterfaceType parent = null;
	if (extendedTypes.size() > 0) {
		parent = extendedTypes.get(0);
	}
	if (extendedTypes.size() == 0) {
		System.out.println(" No Parent!!!");
		return "Still Nonexistent";
	}
	
	String parentClassName = parent.getName().getIdentifier();
	// System.out.println("parent name: " + parentClassName);

	// Optional<ClassOrInterfaceType> scope = parent.getScope();
	// ClassOrInterfaceType classPackage = scope.get();
	// String classPackageName = scope.get().toString();

	// System.out.println("parent scope: " + classPackage);

	// String parentClassPath = getParents(parent);
	// System.out.println("parent path: " + parentClassPath);

	// if (scope.isPresent()) {
	// 	String classPackageName = scope.get().toString();
	// 	parentClassPath = String.format("%s.%s", classPackageName, parentClassName);
	// 	System.out.println("parentClassPath:  " + parentClassPath);
	// }
	// else {
	// 	return "Still Nonexistent";
	// }

	CompilationUnit parentUnit = findParentCompUnit(className, methodName, parentClassName);
	// System.out.println(parentUnit.getPackageDeclaration());
	// System.out.println("parent unit:  " + parentUnit);

	MethodDeclaration method = new MethodDeclaration();

	if (methodName.contains("OBJECT_READER") || methodName.contains("STRING_READER") ||  methodName.contains("[") ) {
		// System.out.println("wtf is this    -- " + methodName);
		String[] splitname = methodName.split("\\[");
		methodName = splitname[0];
		System.out.println("Actual name: " + methodName);
	}

	// look for method in parent instead
	for (TypeDeclaration typeDec : parentUnit.getTypes()) {
			List<BodyDeclaration> members = typeDec.getMembers();
			// System.out.println("members: " members.toString());
			if (members != null) {
				for (BodyDeclaration member : members) {
					if (member.isMethodDeclaration()) {
							method = (MethodDeclaration) member;
							// System.out.println(member);
					try {
						if (methodName.equals(method.getNameAsString())) {
							System.out.println("\"" + methodName + "\" found in parent - \"" + parentClassName + "\"");
							// if method exists, will return here
							return method.toString();	
						}
						else {
							// System.out.print("Method still not found");
							if (parentClassName.equals("TestCase")) {
								System.out.println("Reached Java TestCase");
								return "Still Nonexistent";
							}
						}
					} catch (Exception e) {
						//TODO: handle exception
					}
				}
			}
		}
	}

	if (!parentClassName.equals("TestCase")) {
		System.out.println("Method still does not exist in parent, retrieving parent class path: " + parentClassName);

		String parentClassPath = getParentClassPath(className, methodName, parentClassName);
		// System.out.println("Parent Path : " + parentClassPath);

		// get name of grandparent class 1 level above
		ClassOrInterfaceDeclaration parentType = parentUnit.getType(0).asClassOrInterfaceDeclaration(); 
		NodeList<ClassOrInterfaceType> parentExtendedTypes = parentType.getExtendedTypes();
		// System.out.println(extendedTypes);

		ClassOrInterfaceType grandparent = parentExtendedTypes.get(0);
		String grandparentClassName = grandparent.getName().getIdentifier();
		String grandparentClassPath = getParentClassPath(parentClassName, methodName, grandparentClassName);

		// System.out.println("Grandparent: " + grandparentClassName);
		// System.out.println("Grandparent path: " + grandparentClassPath);

		String grandparentCode = retrieveParentCodeFor(parentClassPath, methodName);
		return grandparentCode;
	}

	return "Still Nonexistent";
}

	private String getParents(ClassOrInterfaceType classOrInterfaceType) {
		StringBuilder parents = new StringBuilder();
		// System.out.println("parent: "+ classOrInterfaceType);
		classOrInterfaceType.walk(Node.TreeTraversal.PARENTS, node -> {

			if (node instanceof ClassOrInterfaceDeclaration) {
				// parents.insert(0, ((ClassOrInterfaceDeclaration) node).getNameAsString());
				// parents.insert(0, '$');
				System.out.println("node is class/interface dec " );
				System.out.println(parents.toString()); 
			}
			if (node instanceof ObjectCreationExpr) {
				parents.insert(0, ((ObjectCreationExpr) node).getType().getNameAsString());
				parents.insert(0, '$');
				System.out.println("node is object creation  " );
			}
			if (node instanceof MethodDeclaration) {
				parents.insert(0, ((MethodDeclaration) node).getNameAsString());
				parents.insert(0, '#');
				System.out.println("node is meth dec " );
			}
			if (node instanceof CompilationUnit) {
				Optional<PackageDeclaration> pkg = ((CompilationUnit) node).getPackageDeclaration();
				if (pkg.isPresent()) {
					parents.replace(0, 1, ".");
					parents.insert(0, pkg.get().getNameAsString());
					System.out.println("node is compilation unit" );
					System.out.println(parents.toString());
				}
			}
		});

		// convert StringBuilder into String and return the String
		return parents.toString();
	}

	private String retrieveCodeFor(String className, String methodName) throws IOException {
		CompilationUnit unit = methodUnit.get(className + "." + methodName);

		// get name of parent class 1 level above
		// ClassOrInterfaceDeclaration type = (ClassOrInterfaceDeclaration) unit.getType(0); 
		// NodeList<ClassOrInterfaceType> extendedTypes = type.getExtendedTypes();
		// ClassOrInterfaceType parentClass = extendedTypes.get(0);
		// String parentClassName = parentClass.getNameAsString();

		MethodDeclaration method = new MethodDeclaration();
		// ArrayList<MethodDeclaration> nonExistentMethods = new ArrayList<MethodDeclaration>();
		// System.out.println(methodName);
		// System.out.println("Unit: " + unit);
		if (methodName.contains("OBJECT_READER") || methodName.contains("STRING_READER") ||  methodName.contains("[") ) {
			// System.out.println("wtf is this    -- " + methodName);
			String[] splitname = methodName.split("\\[");
			methodName = splitname[0];
			System.out.println("Actual name: " + methodName);
		}

		for (TypeDeclaration typeDec : unit.getTypes()) {
				List<BodyDeclaration> members = typeDec.getMembers();
				// System.out.println("members: " members.toString());
				if (members != null) {
					for (BodyDeclaration member : members) {
						if (member.isMethodDeclaration()) {
								method = (MethodDeclaration) member;
								// System.out.println(member);
						try {
							if (methodName.equals(method.getNameAsString())) {
								// if method exists, will return here
								return method.toString();	
							}
							else {
								// System.out.println("Method not found, Parent name: " + parentClassName);
								// CompilationUnit parentUnit = methodUnit.get(parentClassName + "." + methodName);
								// System.out.println(methodName + "	, " + method.getNameAsString());
							}
						} catch (Exception e) {
							//TODO: handle exception
						}
					}
				}
			}
		}
		
		return "Nonexistent";
		// throw new IllegalArgumentException(
		// 		"The method \"" + methodName + "\" does not exist in type \"" + className + "\"!");
	}

	private static Collection<String> extractTestInfoFromSurefireReports() {
		SurefireReportParser parser = new SurefireReportParser(Arrays.asList(new File(SUREFIRE_DIR)),
				Locale.getDefault(), null);
		List<ReportTestSuite> parsed;
		try {
			parsed = parser.parseXMLReportFiles();

			List<String> testCaseNames = parsed.stream().flatMap(a -> a.getTestCases().stream())
					.map(tc -> tc.toString()).collect(Collectors.toList());

			StringBuilder builder = new StringBuilder();
			testCaseNames.stream().map(tc -> tc + "\n").forEach(builder::append);

			Files.write(Paths.get(SUREFIRE_DIR + "/tests.txt"), builder.toString().getBytes());
			return testCaseNames;
		} catch (MavenReportException e) {
			e.printStackTrace();
		} catch (IOException e) {
			e.printStackTrace();
		}

		return Arrays.asList();
	}


}
