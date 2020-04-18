package com.thehellcompany.app;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;
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
import java.util.Properties;
import java.util.Scanner;
import java.util.stream.Collectors;

import org.apache.maven.plugins.surefire.report.ReportTestSuite;
import org.apache.maven.plugins.surefire.report.SurefireReportParser;
import org.apache.maven.reporting.MavenReportException;
import org.pitest.classpath.CodeSource;
import org.pitest.mutationtest.build.DefaultGrouper;
import org.pitest.mutationtest.build.MutationGrouper;
import org.pitest.mutationtest.build.MutationGrouperFactory;

import com.github.javaparser.StaticJavaParser;
import com.github.javaparser.ast.CompilationUnit;
import com.github.javaparser.ast.body.BodyDeclaration;
import com.github.javaparser.ast.body.MethodDeclaration;
import com.github.javaparser.ast.body.TypeDeclaration;

import java.lang.reflect.*;
import java.lang.reflect.Method;
import java.lang.reflect.Modifier;

public class SeparateMethods {

	private static final String SUREFIRE_DIR = "target/surefire-reports";

	private static final String TEST_CODE_DIR = "target/pit-reports/code";

	private Map<String, CompilationUnit> methodUnit = new HashMap<>();


	public static void main(String[] args) throws FileNotFoundException {
		SeparateMethods separateMethods = new SeparateMethods();
		// Collection<String> classAndMethodNames = extractTestInfoFromSurefireReports();
		// Reflections reflections = new Reflections("")

		// reads methods.txt
		Scanner scanner = new Scanner(new File(SUREFIRE_DIR + "/methods.txt"));
		List<String> classAndMethodNames = new ArrayList<String>();
		while (scanner.hasNextLine()) {
			classAndMethodNames.add(scanner.nextLine());
		}
		scanner.close();
		// System.out.println( "Class and method names: " + classAndMethodNames );
		separateMethods.initializeCompilationUnitsForAllClasses(classAndMethodNames);
		separateMethods.extractsingledOutMethodFilesFor(classAndMethodNames);
      
	}
	
	private void removeNonexistentMethods() {

	}

   private void initializeCompilationUnitsForAllClasses(Collection<String> classAndMethodNames) {
		classAndMethodNames.stream().forEach(name -> {

			int delimiter = name.lastIndexOf(".");
			String className = name.substring(0, delimiter);
			String methodName = name.substring(delimiter + 1);

			try {
				initializeCompilationUnitFor(className, methodName);
			} catch (IOException e) {
				e.printStackTrace();
			}
		});
	}

	private void initializeCompilationUnitFor(String className, String methodName) throws IOException {
		if (methodUnit.containsKey(className)) {
			CompilationUnit existingUnit = methodUnit.get(className);
			methodUnit.put(className + "." + methodName, existingUnit);
			return;
		}

		String classPath = className.replace('.', '/');
		Path classLocation = Paths.get("src/test/java/" + classPath + ".java");

		CompilationUnit unit = StaticJavaParser.parse(classLocation);

		methodUnit.put(className + "." + methodName, unit);
		methodUnit.put(className, unit);
	}

	private void extractsingledOutMethodFilesFor(Collection<String> classNames) {

		new File(TEST_CODE_DIR).mkdir(); // create folder to store to

		classNames.stream().forEach(name -> {
			try {
				int delimiter = name.lastIndexOf(".");
				String className = name.substring(0, delimiter);
				String methodName = name.substring(delimiter + 1);

				// System.out.println(className);
				// System.out.println(methodName);

				String code = retrieveCodeFor(className, methodName);

				if (code == "Nonexistent") {
					System.out.println("The method \"" + methodName + "\" does not exist in type \"" + className + "\"!");
					System.out.println("Method not put into file");
				}
				else {
					Files.write(Paths.get(TEST_CODE_DIR + "/" + name + ".txt"), code.getBytes());
				}
				
			} catch (IOException e) {
				e.printStackTrace();
			}
		});

	}

	private String retrieveCodeFor(String className, String methodName) throws IOException {
		CompilationUnit unit = methodUnit.get(className + "." + methodName);
		MethodDeclaration method = new MethodDeclaration();
		ArrayList<MethodDeclaration> nonExistentMethods = new ArrayList<MethodDeclaration>();

		// System.out.println("Unit: " + unit);
		for (TypeDeclaration typeDec : unit.getTypes()) {
				List<BodyDeclaration> members = typeDec.getMembers();
				if (members != null) {
					for (BodyDeclaration member : members) {
						if (member.isMethodDeclaration()) {
								method = (MethodDeclaration) member;
						try {
							if (methodName.equals(method.getNameAsString())) {
								return method.toString();	
							}
							// else {
							// 	System.out.println("The method \"" + methodName + "\" does not exist in type \"" + className + "\"!");
							// 	System.out.println("Added method to bin");
							// 	nonExistentMethods.add(method);
							// }
						} catch (Exception e) {
							//TODO: handle exception
						}
					}
				}
				// if (nonExistentMethods.isEmpty() != true) {
				// 	for (int i = 0; i < nonExistentMethods.size(); i++ ) {
				// 		System.out.println("Non existent method deleted: " + nonExistentMethods.get(i).getNameAsString());
				// 		nonExistentMethods.get(i).remove();
				// 	}		
				// }
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
