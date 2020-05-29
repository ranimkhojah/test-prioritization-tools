package com.thehellcompany.app;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.Arrays;
import java.util.Collection;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Properties;
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

public class SingleMutationAtaTimeGrouperFactory implements MutationGrouperFactory {

	private static final String SUREFIRE_DIR = "target/surefire-reports";

	private static final String TEST_CODE_DIR = "target/pit-reports/code";

	private Map<String, CompilationUnit> methodUnit = new HashMap<>();

	@Override
	public String description() {
		return "Single at a time";
	}

	@Override
	public MutationGrouper makeFactory(final Properties props, final CodeSource codeSource, final int numberOfThreads,
			final int unitSize) {
		Collection<String> classAndMethodNames = extractTestInfoFromSurefireReports();
		initializeCompilationUnitsForAllClasses(classAndMethodNames);
		extractsingledOutMethodFilesFor(classAndMethodNames);
		return new DefaultGrouper(1);
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

				String code = retrieveCodeFor(className, methodName);
				Files.write(Paths.get(TEST_CODE_DIR + "/" + name), code.getBytes());
			} catch (IOException e) {
				e.printStackTrace();
			}
		});

	}

	private String retrieveCodeFor(String className, String methodName) throws IOException {
		CompilationUnit unit = methodUnit.get(className + "." + methodName);

		for (TypeDeclaration typeDec : unit.getTypes()) {
			List<BodyDeclaration> members = typeDec.getMembers();
			if (members != null) {
				for (BodyDeclaration member : members) {
					if (member.isMethodDeclaration()) {
						MethodDeclaration method = (MethodDeclaration) member;
						if (methodName.equals(method.getNameAsString()))
							return method.toString();
					}
				}
			}
		}

		throw new IllegalArgumentException(
				"The method \"" + methodName + "\" does not exist in type \"" + className + "\"!");
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
